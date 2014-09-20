//
//  ReviewsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ReviewsViewController.h"

#import "LongStringTableViewCell.h"

@interface ReviewsViewController ()

@end

@implementation ReviewsViewController

@synthesize setlist;

- (id)initWithSetlist:(PhishNetSetlist *)s {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
		self.setlist = s;
        self.title = @"Reviews";
        
        [self.tableView registerClass:LongStringTableViewCell.class
               forCellReuseIdentifier:@"reviewText"];
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
    UITableViewCell *cell;
    
	PhishNetReview *review = self.setlist.reviews[indexPath.section];
	if(indexPath.row == 0) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:@"cell"];

		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		NSString *dateString = [dateFormatter stringFromDate:review.timestamp];

		cell.textLabel.text = review.author;
		cell.detailTextLabel.text = dateString;
	}
	else if(indexPath.row == 1) {
        LongStringTableViewCell *lsc = [tableView dequeueReusableCellWithIdentifier:@"reviewText"
                                                                       forIndexPath:indexPath];
        
        [lsc updateCellWithString:review.review
                          andFont:nil];
        
        cell = lsc;
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == 0) {
		return (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight);
	}
	
	PhishNetReview *review = self.setlist.reviews[indexPath.section];

	LongStringTableViewCell *lsc = [tableView dequeueReusableCellWithIdentifier:@"reviewText"];
    return [lsc heightForCellWithString:review.review
                                andFont:nil
                            inTableView:tableView];
}

@end
