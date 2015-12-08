//
//  RLVenuesViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLVenuesViewController.h"

#import "IGAPIClient.h"
#import "RLShowCollectionViewController.h"
#import "NowPlayingBarViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@interface RLVenuesViewController ()

@property (nonatomic) NSArray *venues;
@property (nonatomic) NSMutableArray *searchVenues;

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation RLVenuesViewController

- (instancetype)init {
    if (self = [super init]) {
        self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Venues"
                                                      image:[UIImage imageNamed:@"glyphicons-27-road"]
                                                        tag:0];
        
        self.navigationController.tabBarItem = self.tabBarItem;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
    } else {
        [AppDelegate.sharedDelegate.navDelegate fixForViewController:self force:true];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = @"Venues";
}

- (void)refresh:(id)sender {
   [IGAPIClient.sharedInstance venues:^(NSArray *venues) {
       self.venues = [venues sortedArrayUsingComparator:^NSComparisonResult(IGVenue *obj1, IGVenue *obj2) {
           return [obj1.name compare:obj2.name];
       }];
       self.searchVenues = self.venues.mutableCopy;
       
       [self.tableView reloadData];
       [super refresh:sender];
   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.searchVenues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:@"cell"];
    }
    
    IGVenue *ven = self.searchVenues[indexPath.row];
    
    cell.textLabel.text = ven.name;
    cell.detailTextLabel.text = ven.city;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:MIN(cell.textLabel.font.pointSize, 28)];
    cell.detailTextLabel.font = [UIFont fontWithName:cell.detailTextLabel.font.fontName size:MIN(cell.detailTextLabel.font.pointSize, 26)];
    cell.textLabel.adjustsFontSizeToFitWidth = true;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    RLShowCollectionViewController *vc = [RLShowCollectionViewController.alloc initWithVenue:self.searchVenues[indexPath.row]];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f * 1.2f;
}

#pragma mark - Search results updater

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    self.searchVenues = (NSMutableArray *)self.venues.mutableCopy;
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchText];
        [self.searchVenues filterUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

@end
