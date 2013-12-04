//
//  BaseStatsViewController.h
//  Phish Tracks
//
//  There are two assumptions for how stats are displayed with this controller:
//    - that if there are scalar stats, they come before any nonscalar stats in the query result
//    - there is only one nonscalar stat
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"
#import "PhishTracksStatsPlayEvent.h"
#import "RankingTableViewCell.h"

@interface BaseStatsViewController : RefreshableTableViewController {
	PhishTracksStatsQuery *query;
	PhishTracksStatsQueryResults *queryResults;
}

- (id)initWithTitle:(NSString *)title andStatsQuery:(PhishTracksStatsQuery *)statsQuery;
- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier;
//- (NSString *)topNIdentifier;
- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play;

@end
