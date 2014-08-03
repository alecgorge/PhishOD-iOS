//
//  ConcertInfoViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "LongStringViewController.h"
#import "ReviewsViewController.h"
#import "NSString+stripHTML.h"
#import "LongStringTableViewCell.h"

@interface LongStringViewController ()

@property (nonatomic) BOOL useAttributedString;

@property (nonatomic) NSString *contentString;
@property (nonatomic) NSAttributedString *attributedString;

@end

@implementation LongStringViewController

- (id)initWithString:(NSString*)s {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.contentString = s;
    }
    return self;
}

- (instancetype)initWithAttributedString:(NSAttributedString *)s {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.attributedString = s;
        self.useAttributedString = YES;
    }
    return self;
}

- (instancetype)initWithHTML:(NSString *)s {
    NSMutableAttributedString *a = [[NSAttributedString alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                              NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                         documentAttributes:nil
                                                                      error:nil].mutableCopy;
    
    [a addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: UIFont.systemFontSize]}
               range:NSMakeRange(0, a.length)];
    
    if (self = [self initWithAttributedString:a]) {
        
    }
    return self;
}

#pragma mark - Table view data source

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:LongStringTableViewCell.class
           forCellReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LongStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                                    forIndexPath:indexPath];
    
    UIFont *font = [UIFont systemFontOfSize: UIFont.systemFontSize];
	
	if(self.monospace) {
		font = [UIFont fontWithName:@"Courier"
							   size:13.0f];
	}

    if(self.useAttributedString) {
        [cell updateCellWithAttributedString:self.attributedString];
    }
    else {
        [cell updateCellWithString:self.contentString
                           andFont:font];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LongStringTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIFont *font = [UIFont systemFontOfSize: UIFont.systemFontSize];
	
	if(self.monospace) {
		font = [UIFont fontWithName:@"Courier"
							   size:13.0f];
	}
    
    if(self.useAttributedString) {
        return [cell heightForCellWithAttributedString:self.attributedString
                                           inTableView:tableView];
    }
    else {
        return [cell heightForCellWithString:self.contentString
                                     andFont:font
                                 inTableView:tableView];
    }
}

@end
