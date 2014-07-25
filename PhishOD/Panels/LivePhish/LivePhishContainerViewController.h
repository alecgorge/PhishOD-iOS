//
//  LivePhishContainerViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@class LivePhishContainer;

@interface LivePhishContainerViewController : RefreshableTableViewController

- (instancetype)initWithContainer:(LivePhishContainer *)container;

@end
