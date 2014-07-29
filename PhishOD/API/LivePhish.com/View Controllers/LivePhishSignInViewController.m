//
//  LivePhishSignInViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishSignInViewController.h"

#import "LivePhishAuth.h"

@interface LivePhishSignInViewController () <UITextFieldDelegate>

@property (nonatomic) UITextField *uiUsername;
@property (nonatomic) UITextField *uiPassword;

@end

@implementation LivePhishSignInViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign Into LivePhish";
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
    
    UIBarButtonItem *dismiss = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                           target:self
                                                                           action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = dismiss;
}

- (void)dismiss {
    [self.delegate dismissTappedInSignInViewController:self];
}

- (void)signIn {
    [self.delegate signInViewController:self
               tappedSignInWithUsername:self.uiUsername.text
                            andPassword:self.uiPassword.text];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.uiUsername) {
        [self.uiPassword becomeFirstResponder];
    }
    else if(textField == self.uiPassword) {
        [self.uiPassword resignFirstResponder];
        [self signIn];
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Email";
            
            self.uiUsername = [UITextField.alloc initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width / 1.75, 30.f)];
            
            self.uiUsername.placeholder = @"demo@example.com";
            self.uiUsername.keyboardType = UIKeyboardTypeEmailAddress;
            self.uiUsername.autocorrectionType = UITextAutocorrectionTypeNo;
            self.uiUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.uiUsername.returnKeyType = UIReturnKeyNext;
            self.uiUsername.delegate = self;
            
            cell.accessoryView = self.uiUsername;
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = @"Password";
            
            self.uiPassword = [UITextField.alloc initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width / 1.75, 30.f)];
            
            self.uiPassword.placeholder = @"**********";
            self.uiPassword.keyboardType = UIKeyboardTypeEmailAddress;
            self.uiPassword.autocorrectionType = UITextAutocorrectionTypeNo;
            self.uiPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.uiPassword.secureTextEntry = YES;
            self.uiPassword.returnKeyType = UIReturnKeyDone;
            self.uiPassword.delegate = self;
            
            cell.accessoryView = self.uiPassword;
        }
    }
    else {
        cell.textLabel.text = @"Sign In";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        if(self.uiUsername.text.length > 0 && self.uiPassword.text.length > 0) {
            [self signIn];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Your email and password are stored securely in your device's keychain and are only used solely for direct communication with LivePhish.com\n\nPhishOD is not affiliated with Phish, nugs.net or LivePhish in any way. This is simply provided as a free service to the community until the LivePhish app is updated.";
    }
    
    return nil;
}

@end
