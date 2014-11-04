//
//  RefreshableTableViewController.m
//  Adminium
//
//  Created by Alec Gorge on 6/18/13.
//  Copyright (c) 2013 Ramblingwood. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import <CSNNotificationObserver/CSNNotificationObserver.h>

@interface RefreshableTableViewController () {
    CSNNotificationObserver *_contentResizeNotification;
    BOOL _requestedPreventRefresh;
}

@end

@implementation RefreshableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.sectionIndexColor = COLOR_PHISH_GREEN;
    
    if(!self.preventRefresh) {
        UIRefreshControl *c = [[UIRefreshControl alloc] init];
        [c addTarget:self
              action:@selector(refresh:)
    forControlEvents:UIControlEventValueChanged];
        self.refreshControl = c;
        [self beginRefreshingTableView];
        
        [self refresh: self.refreshControl];
    }
    
    _contentResizeNotification = [CSNNotificationObserver.alloc initWithName:UIContentSizeCategoryDidChangeNotification
                                                                      object:nil
                                                                       queue:NSOperationQueue.mainQueue
                                                                  usingBlock:^(NSNotification *notification) {
                                                                      [self.tableView reloadData];
                                                                  }];
}

- (void)refresh:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _requestedPreventRefresh = YES;
    [self.refreshControl endRefreshing];
}

- (void)beginRefreshingTableView {
	// send to iteration of redraw loop
//    [self _beginRefreshing];
    
    _requestedPreventRefresh = NO;
    [self performSelector:@selector(_beginRefreshing)
               withObject:nil
               afterDelay:0.2];
}

- (void)_beginRefreshing {
    if(_requestedPreventRefresh == YES) {
        _requestedPreventRefresh = NO;
        return;
    }
    
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
