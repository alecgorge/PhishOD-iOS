//
//  RLYearViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/29/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLYearViewController.h"

#import "RLShowSourcesViewController.h"

#import "IGShowCell.h"

@interface RLYearViewController ()

@end

@implementation RLYearViewController

- (instancetype)initWithYear:(IGYear *)year {
    if (self = [super init]) {
        self.year = year;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%ld", self.year.year];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"show"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70.0f;
}

- (void)refresh:(id)sender {
    [IGAPIClient.sharedInstance year:self.year.year
                             success:^(IGYear *y) {
                                 self.year = y;
                                 
                                 [self.tableView reloadData];
                                 [super refresh:sender];
                             }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.year.shows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.year.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
                                                       forIndexPath:indexPath];
    
    [cell updateCellWithShow:self.year.shows[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGShow *show = self.year.shows[indexPath.row];
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:show.displayDate];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
