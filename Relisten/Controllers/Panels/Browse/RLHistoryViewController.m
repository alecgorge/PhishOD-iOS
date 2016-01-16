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
#import "IGAPIClient.h"
#import "RLShowSourcesViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface RLHistoryViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic) NSMutableOrderedSet<IGShow *> *history;

@end

@implementation RLHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.title = @"Recent";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"showCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0f;
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.tableView.tableFooterView = UIView.new;
    
    self.history = NSMutableOrderedSet.orderedSet;
    
    for (IGShow *show in PHODHistory.sharedInstance.history) {
        if(show.ArtistId == IGAPIClient.sharedInstance.artist.id) {
            [self.history addObject:show];
        }
    }
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
    return self.history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"
                                                       forIndexPath:indexPath];
    
    [cell updateCellWithShow:self.history[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGShow *show = self.history[indexPath.row];
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
