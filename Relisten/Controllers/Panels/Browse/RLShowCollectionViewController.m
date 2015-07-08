//
//  RLYearViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/29/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLShowCollectionViewController.h"

#import "RLShowSourcesViewController.h"

#import "IGShowCell.h"

@interface RLShowCollectionViewController ()

@property (nonatomic) NSArray *shows;

@end

@implementation RLShowCollectionViewController

- (instancetype)initWithYear:(IGYear *)year {
    if (self = [super init]) {
        self.year = year;
        self.venue = nil;
    }
    return self;
}

- (instancetype)initWithVenue:(IGVenue *)venue {
    if (self = [super init]) {
        self.year = nil;
        self.venue = venue;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"show"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70.0f;
    
    [self updateTitle];
}

- (void)updateTitle {
    if (self.year) {
        self.title = [NSString stringWithFormat:@"%ld", self.year.year];
    }
    else if(self.venue) {
        self.title = self.venue.name;
    }
}

- (void)refresh:(id)sender {
    if(self.year) {
        [IGAPIClient.sharedInstance year:self.year.year
                                 success:^(IGYear *y) {
                                     self.year = y;
                                     self.shows = self.year.shows;
                                     
                                     [self updateTitle];
                                     
                                     [self.tableView reloadData];
                                     [super refresh:sender];
                                 }];
    }
    else if(self.venue) {
        [IGAPIClient.sharedInstance venue:self.venue
                                  success:^(IGVenue *ven) {
                                      self.venue = ven;
                                      
                                      self.shows = self.venue.shows;
                                      
                                      [self updateTitle];
                                      
                                      [self.tableView reloadData];
                                      [super refresh:sender];
                                  }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.shows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
                                                       forIndexPath:indexPath];
    
    [cell updateCellWithShow:self.shows[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGShow *show = self.shows[indexPath.row];
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:show.displayDate];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
