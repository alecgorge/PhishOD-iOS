//
//  RLShowViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/5/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@class IGShow;

@interface RLShowViewController : RefreshableTableViewController <UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) IGShow *show;

- (instancetype)initWithShow:(IGShow *)show;

@end
