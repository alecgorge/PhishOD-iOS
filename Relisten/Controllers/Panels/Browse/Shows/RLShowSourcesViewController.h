//
//  RLShowSourcesViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import "IGAPIClient.h"
#import "AppDelegate.h"

@interface RLShowSourcesViewController : RefreshableTableViewController

- (instancetype)initWithDisplayDate:(NSString *)displayDate;
- (instancetype)initWithRandomDate;

@property (nonatomic) NSArray *fullShows;

@end
