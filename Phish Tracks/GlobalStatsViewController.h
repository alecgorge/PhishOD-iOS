//
//  GlobalStatsViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface GlobalStatsViewController : RefreshableTableViewController

@property NSDictionary *stats;
@property NSArray *history;

@end
