//
//  StatsRegistrationViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StatsRegistrationViewController.h"
#import "PhishTracksStats.h"

@interface StatsRegistrationViewController ()

@end

@implementation StatsRegistrationViewController {
	UITextField *usernameTextField;
	UITextField *emailTextField;
	UITextField *passwordTextField;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		self.title = @"Sign up";
		[self.tableView setAutoresizesSubviews:YES];

		usernameTextField = [[UITextField alloc] init];
		usernameTextField.adjustsFontSizeToFitWidth = YES;
		usernameTextField.placeholder = @"Required";
		usernameTextField.keyboardType = UIKeyboardTypeDefault;
		usernameTextField.returnKeyType = UIReturnKeyNext;
		usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
		usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
		usernameTextField.delegate = self;
		usernameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		emailTextField = [[UITextField alloc] init];
		emailTextField.adjustsFontSizeToFitWidth = YES;
		emailTextField.placeholder = @"Required";
		emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
		emailTextField.returnKeyType = UIReturnKeyNext;
		emailTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
		emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
		emailTextField.delegate = self;
		emailTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		passwordTextField = [[UITextField alloc] init];
		passwordTextField.adjustsFontSizeToFitWidth = YES;
		passwordTextField.placeholder = @"Required";
		passwordTextField.keyboardType = UIKeyboardTypeDefault;
		passwordTextField.returnKeyType = UIReturnKeyDone;
		passwordTextField.secureTextEntry = YES;
		passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
		passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
		passwordTextField.delegate = self;
		passwordTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 3;
	}
	else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier;
	UITableViewCell *cell;

	if (indexPath.section == 0 && indexPath.row == 0) {
		CellIdentifier = @"UsernameTextFieldCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
			cell.textLabel.text = @"Username";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			CGRect bounds = CGRectMake(110, cell.bounds.origin.y, cell.bounds.size.width - 110, cell.bounds.size.height);
			usernameTextField.frame = bounds;
			[cell.contentView addSubview:usernameTextField];
		}
	}
	else if (indexPath.section == 0 && indexPath.row == 1) {
		CellIdentifier = @"EmailTextFieldCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
			cell.textLabel.text = @"Email";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			CGRect bounds = CGRectMake(110, cell.bounds.origin.y, cell.bounds.size.width - 110, cell.bounds.size.height);
			emailTextField.frame = bounds;
			[cell.contentView addSubview:emailTextField];
		}
	}
	else if (indexPath.section == 0 && indexPath.row == 2) {
		CellIdentifier = @"PasswordTextFieldCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
			cell.textLabel.text = @"Password";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			CGRect bounds = CGRectMake(110, cell.bounds.origin.y, cell.bounds.size.width - 110, cell.bounds.size.height);
			passwordTextField.frame = bounds;
			[cell.contentView addSubview:passwordTextField];
		}
	}
	else {
		CellIdentifier = @"Cell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if(!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
		}

		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"Sign up";
	}

    return cell;
}

- (void)createRegistrationHelper
{
	[[PhishTracksStats sharedInstance] createRegistration:usernameTextField.text email:emailTextField.text password:passwordTextField.text
    success:^()
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	failure:^(PhishTracksStatsError *error)
	{
//		NSArray *validationErrors = error.userInfo[@"errors"];
//		NSString *alertMessage = [validationErrors count] > 0 ? [validationErrors objectAtIndex:0] : error.userInfo[@"message"];
		[FailureHandler showAlertWithStatsError:error];

//		dbug(@"[stats] createSession failure error_code=%d message='%@'", error.code, error.userInfo[@"message"]);

		if (error.code == kStatsApiKeyRequired)
			[self.navigationController popViewControllerAnimated:YES];
	}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
		[self createRegistrationHelper];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameTextField) {
        [textField resignFirstResponder];
        [emailTextField becomeFirstResponder];
    }
	else if (textField == emailTextField) {
        [textField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
	}
	else if (textField == passwordTextField) {
		[self createRegistrationHelper];
	}

	return YES;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
