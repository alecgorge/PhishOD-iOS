//
//  ReviewsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ReviewsViewController.h"

@interface ReviewsViewController ()

@end

@implementation ReviewsViewController

@synthesize setlist;

- (id)initWithSetlist:(PhishNetSetlist *)s {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.setlist = s;
        self.title = @"Reviews";
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.setlist.reviews.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 2;
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
	
	PhishNetReview *review = self.setlist.reviews[indexPath.section];
	if(indexPath.row == 0) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:CellIdentifier];

		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		NSString *dateString = [dateFormatter stringFromDate:review.timestamp];

		cell.textLabel.text = review.author;
		cell.detailTextLabel.text = dateString;
	}
	else if(indexPath.row == 1) {
		cell.textLabel.text = review.review;
		cell.textLabel.font = [UIFont systemFontOfSize: [UIFont systemFontSize]];
		cell.textLabel.numberOfLines = 0;
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == 0) {
		return tableView.rowHeight;
	}
	
	// Get the text so we can measure it
	NSString *text = ((PhishNetReview*)self.setlist.reviews[indexPath.section]).review;
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
