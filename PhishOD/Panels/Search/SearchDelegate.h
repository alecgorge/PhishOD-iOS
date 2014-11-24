//
//  SearchDelegate.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIScrollView+EmptyDataSet.h"

@interface SearchDelegate : NSObject<UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic) PhishinSearchResults *results;

- (instancetype)initWithTableView:(UITableView*)tableView
		  andNavigationController:(UINavigationController*)nav;

@end
