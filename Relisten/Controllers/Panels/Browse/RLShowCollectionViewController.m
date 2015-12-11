//
//  RLYearViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/29/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLShowCollectionViewController.h"

#import "RLShowSourcesViewController.h"
#import "NowPlayingBarViewController.h"

#import "IGShowCell.h"

typedef NS_ENUM(NSInteger, RLShowCollectionType) {
    RLShowCollectionYear,
    RLShowCollectionVenue,
    RLShowCollectionTopShows
};

@interface RLShowCollectionViewController ()

@property (nonatomic) NSArray *shows;
@property (nonatomic) RLShowCollectionType collectionType;

@property (nonatomic) NSMutableArray *searchShows;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation RLShowCollectionViewController

- (instancetype)initWithYear:(IGYear *)year {
    if (self = [super init]) {
        self.year = year;
        self.venue = nil;
        self.collectionType = RLShowCollectionYear;
    }
    return self;
}

- (instancetype)initWithVenue:(IGVenue *)venue {
    if (self = [super init]) {
        self.year = nil;
        self.venue = venue;
        self.collectionType = RLShowCollectionVenue;
    }
    return self;
}

- (instancetype)initWithTopShows {
    if (self = [super init]) {
        self.year = nil;
        self.venue = nil;
        self.collectionType = RLShowCollectionTopShows;
        
        self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Top Shows"
                                                      image:[UIImage imageNamed:@"glyphicons-80-signal"]
                                                        tag:0];
        
        self.navigationController.tabBarItem = self.tabBarItem;
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
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTitle];
}

- (void)updateTitle {
    if(self.collectionType == RLShowCollectionYear) {
        self.navigationItem.title = self.title = [NSString stringWithFormat:@"%ld", self.year.year];
    }
    else if(self.collectionType == RLShowCollectionVenue) {
        self.navigationItem.title = self.title = self.venue.name;
    }
    else if(self.collectionType == RLShowCollectionTopShows) {
        self.navigationItem.title = self.title = @"Top Shows";
    }
}

- (void)refresh:(id)sender {
    if(self.collectionType == RLShowCollectionYear) {
        [IGAPIClient.sharedInstance year:self.year.year
                                 success:^(IGYear *y) {
                                     self.year = y;
                                     self.shows = self.year.shows;
                                     self.searchShows = [[NSMutableArray alloc] initWithArray:self.shows];
                                     
                                     [self updateTitle];
                                     
                                     [self.tableView reloadData];
                                     [super refresh:sender];
                                 }];
    }
    else if(self.collectionType == RLShowCollectionVenue) {
        [IGAPIClient.sharedInstance venue:self.venue
                                  success:^(IGVenue *ven) {
                                      self.venue = ven;
                                      
                                      self.shows = self.venue.shows;
                                      self.searchShows = [[NSMutableArray alloc] initWithArray:self.shows];
                                      
                                      [self updateTitle];
                                      
                                      [self.tableView reloadData];
                                      [super refresh:sender];
                                  }];
    }
    else if(self.collectionType == RLShowCollectionTopShows) {
        [IGAPIClient.sharedInstance topShows:^(NSArray *shows) {
            self.shows = shows;
            self.searchShows = [[NSMutableArray alloc] initWithArray:self.shows];
            
            [self updateTitle];
            
            [self.tableView reloadData];
            [super refresh:sender];
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchShows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.searchShows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
                                                       forIndexPath:indexPath];
    
    [cell updateCellWithShow:self.searchShows[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGShow *show = self.searchShows[indexPath.row];
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:show.displayDate];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

#pragma mark - Search results updater

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    self.searchShows = (NSMutableArray *)self.shows.mutableCopy;
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.displayDate CONTAINS[c] %@", searchText];
        [self.searchShows filterUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

@end
