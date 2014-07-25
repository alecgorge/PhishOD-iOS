//
//  LivePhishCategoryViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@class LivePhishCategory, LivePhishStash;

@interface LivePhishCategoryViewController : RefreshableTableViewController

- (instancetype)initWithCategory:(LivePhishCategory *)cat;
- (instancetype)initWithStash;

@end
