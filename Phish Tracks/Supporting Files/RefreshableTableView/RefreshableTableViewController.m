//
//  RefreshableTableViewController.m
//  Adminium
//
//  Created by Alec Gorge on 6/18/13.
//  Copyright (c) 2013 Ramblingwood. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface RefreshableTableViewController ()

@end

@implementation RefreshableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	UIRefreshControl *c = [[UIRefreshControl alloc] init];
	[c addTarget:self
		  action:@selector(refresh:)
forControlEvents:UIControlEventValueChanged];
	self.refreshControl = c;
	[self beginRefreshingTableView];
	
	[self refresh: self.refreshControl];
}

- (void)refresh:(id)sender {
	[sender endRefreshing];
}

- (void)beginRefreshingTableView {
	
    [self.refreshControl beginRefreshing];
	
    if (self.tableView.contentOffset.y == 0) {
		
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
			
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
			
        } completion:^(BOOL finished){
			
        }];
		
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

@end
