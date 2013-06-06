//
//  ConcertInfoViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ConcertInfoViewController.h"
#import "ReviewsViewController.h"
#import "NSString+stripHTML.h"

@interface ConcertInfoViewController ()

@end

@implementation ConcertInfoViewController

- (id)initWithSetlist:(PhishNetSetlist*)s {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.setlist = s;
		self.title = @"Concert Notes";
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
	
	if(indexPath.section == 0) {
		cell.textLabel.text = self.setlist.setlistNotes;
	}
	else if(indexPath.section == 1) {
		cell.textLabel.text = self.setlist.setlistHTML;
	}

	cell.textLabel.font = [UIFont systemFontOfSize: [UIFont systemFontSize]];
	cell.textLabel.numberOfLines = 0;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get the text so we can measure it
	NSString *text = @"";
	if (indexPath.section == 0) {
		text = self.setlist.setlistNotes;
	}
	else {
		text = self.setlist.setlistHTML;
	}
	
	// Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(tableView.frame.size.width - 20.0f - (10.0f * 2), 20000.0f);
	// Get the size of the text given the CGSize we just made as a constraint
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize: [UIFont systemFontSize]]
				   constrainedToSize:constraint
					   lineBreakMode:UILineBreakModeWordWrap];
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	CGFloat height = MAX(size.height, tableView.rowHeight);
	// return the height, with a bit of extra padding in
	return height + (10.0f * 2);
}

@end
