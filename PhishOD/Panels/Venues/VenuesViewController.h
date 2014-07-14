//
//  VenuesViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface VenuesViewController : RefreshableTableViewController<UISearchDisplayDelegate>

@property (nonatomic) NSArray *venues;
@property (nonatomic) NSArray *indicies;
@property (nonatomic) NSArray *results;

@end
