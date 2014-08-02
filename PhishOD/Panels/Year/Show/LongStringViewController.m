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

@interface LongStringViewController ()

@property (nonatomic) NSString *contentString;

@end

@implementation LongStringViewController

- (id)initWithString:(NSString*)s {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.contentString = s;
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = self.contentString;

	cell.textLabel.font = [UIFont systemFontOfSize: UIFont.systemFontSize];
	
	if(self.monospace) {
		cell.textLabel.font = [UIFont fontWithName:@"Courier"
											  size:13.0f];
	}
	
	cell.textLabel.numberOfLines = 0;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get the text so we can measure it
	NSString *text = self.contentString;
	
	UIFont *font = [UIFont systemFontOfSize: UIFont.systemFontSize];
	
	if(self.monospace) {
		font = [UIFont fontWithName:@"Courier"
							   size:13.0f];
	}

	// Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(tableView.frame.size.width - (15.0f * 2), CGFLOAT_MAX);
	
	// Get the size of the text given the CGSize we just made as a constraint
	CGRect rect = [text boundingRectWithSize:constraint
									 options:NSStringDrawingUsesLineFragmentOrigin
								  attributes:@{NSFontAttributeName: font}
									 context:nil];
	
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	CGFloat height = MAX(rect.size.height, tableView.rowHeight);
	
	// return the height, with a bit of extra padding in
	return height + (10.0f * 2);
}

@end
