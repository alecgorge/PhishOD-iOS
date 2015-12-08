//
//  RLHistoryViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/18/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLHistoryViewController.h"

#import "PHODHistory.h"

#import "IGShowCell.h"
#import "RLShowSourcesViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface RLHistoryViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@end

@implementation RLHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Recent";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"showCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f;
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.tableView.tableFooterView = UIView.new;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return PHODHistory.sharedInstance.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"
                                                       forIndexPath:indexPath];
    
    [cell updateCellWithShow:PHODHistory.sharedInstance.history[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGShow *show = PHODHistory.sharedInstance.history[indexPath.row];
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:show.displayDate];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [NSAttributedString.alloc initWithString:@"You haven't listened to any shows yet :("];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    return [NSAttributedString.alloc initWithString:@"Listen to a random show »"];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self.navigationController pushViewController:[RLShowSourcesViewController.alloc initWithRandomDate]
                                         animated:YES];
}

@end
