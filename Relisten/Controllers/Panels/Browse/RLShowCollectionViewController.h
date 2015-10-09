//
//  RLYearViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 6/29/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import "IGAPIClient.h"

@interface RLShowCollectionViewController : RefreshableTableViewController <UISearchResultsUpdating>

- (instancetype)initWithYear:(IGYear *)year;
- (instancetype)initWithVenue:(IGVenue *)venue;
- (instancetype)initWithTopShows;

@property (nonatomic) IGYear *year;
@property (nonatomic) IGVenue *venue;

@end
