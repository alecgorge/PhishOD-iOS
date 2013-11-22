//
//  BaseStatsViewController.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"

@interface BaseStatsViewController : RefreshableTableViewController {
	PhishTracksStatsQuery *query;
	PhishTracksStatsQueryResults *queryResults;
}

@end
