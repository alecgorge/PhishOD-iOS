//
//  RLYearViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 6/29/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import "IGAPIClient.h"

@interface RLYearViewController : RefreshableTableViewController

- (instancetype)initWithYear:(IGYear *)year;

@property (nonatomic) IGYear *year;

@end
