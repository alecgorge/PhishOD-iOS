//
//  RLShowViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/5/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLShowViewController.h"

#import <CSNNotificationObserver/CSNNotificationObserver.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "AppDelegate.h"
#import "AGMediaPlayerViewController.h"
#import "IGAPIClient.h"
#import "IGDurationHelper.h"
#import "IguanaMediaItem.h"
#import "RLShowReviewsViewController.h"
#import "IGSourceCell.h"
#import "RLShowCollectionViewController.h"
#import "PHODFavoritesManager.h"
#import "RLSourceDetailsViewController.h"

#import "PHODTrackCell.h"

NS_ENUM(NSInteger, IGShowSections) {
    IGShowSectionInfo,
    IGShowSectionTracks,
    IGShowSectionCount,
};

NS_ENUM(NSInteger, IGShowRows) {
    IGShowRowSource,
//    IGShowRowReviews,
//    IGShowRowVenue,
    IGShowRowFavorite,
//    IGShowRowDownloadAll,
    IGShowRowCount
};

@interface RLShowViewController ()

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;

@property (nonatomic) BOOL inSearchMode;
@property (nonatomic, strong) NSMutableArray *searchTracks;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation RLShowViewController

- (instancetype)initWithShow:(IGShow *)show {
    if(self = [super initWithStyle:UITableViewStylePlain]) {
        self.show = show;
        self.searchTracks = self.show.tracks.mutableCopy;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.title = self.show.displayDate;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:@"track"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGSourceCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:@"source"];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [self.tableView reloadData];
                                                                }];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
    
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self.tableView reloadData];
    }];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchController:)];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}

- (IBAction)showSearchController:(id)sender {
    self.inSearchMode = YES;
    self.searchController.searchBar.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.searchController.searchBar.alpha = 1;
    } completion:^(BOOL finished){
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.searchController.searchBar becomeFirstResponder];
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    
}

- (void)refresh:(UIRefreshControl *)sender {
    [super refresh:sender];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return IGShowSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if(section == IGShowSectionInfo) {
        return self.inSearchMode ? 0 : IGShowRowCount;
    }
    
    return self.searchTracks.count;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController.delegate navigationController:self.navigationController
                                       didShowViewController:self
                                                    animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    if(section == IGShowSectionInfo) {
        if (indexPath.row == IGShowRowSource) {
            IGSourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"source"
                                                                 forIndexPath:indexPath];
            
            [cell updateCellWithSource:self.show
                           inTableView:tableView];
            
            return cell;
        }
        /*
        else if(indexPath.row == IGShowRowReviews) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
            
            if (!cell) {
                cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"plain"];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"Read %lu reviews", self.show.reviews.count];
            cell.textLabel.adjustsFontSizeToFitWidth = true;
            cell.detailTextLabel.text = nil;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
        else if(indexPath.row == IGShowRowVenue) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
            
            if (!cell) {
                cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"plain"];
            }
            
            cell.textLabel.text = @"Venue";
            cell.textLabel.adjustsFontSizeToFitWidth = true;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", self.show.venue.name, self.show.venue.city];
            cell.detailTextLabel.adjustsFontSizeToFitWidth = true;
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
         */
        else if(indexPath.row == IGShowRowFavorite) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
            
            if (!cell) {
                cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"plain"];
            }
            
            if([PHODFavoritesManager.sharedInstance showDateIsAFavorite:self.show.displayDate]) {
                cell.textLabel.text = @"Unfavorite this show";
            }
            else {
                cell.textLabel.text = @"Favorite this show";
            }
            cell.textLabel.adjustsFontSizeToFitWidth = true;
            cell.detailTextLabel.text = @"";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
        /*
        else if(indexPath.row == IGShowRowDownloadAll) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
            
            if (!cell) {
                cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"plain"];
            }
            
            cell.textLabel.text = @"Download the whole show";
            cell.detailTextLabel.text = @"";
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
         */
    }
    else {
        PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"
                                                              forIndexPath:indexPath];
        
        IGTrack *track = self.searchTracks[indexPath.row];
        
        [cell updateCellWithTrack:track
                      inTableView:tableView];
        
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == IGShowSectionTracks) {
        return @"Tracks";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    NSUInteger row = indexPath.row;
    
    if(indexPath.section == IGShowSectionInfo) {
        if(row == IGShowRowSource) {
            RLSourceDetailsViewController *vc = [RLSourceDetailsViewController.alloc initWithShowViewController:self];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        /*
        if(row == IGShowRowReviews) {
            RLShowReviewsViewController *vc = [RLShowReviewsViewController.alloc initWithShow:self.show];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        else if(row == IGShowRowVenue) {
            RLShowCollectionViewController *vc = [RLShowCollectionViewController.alloc initWithVenue:self.show.venue];
            
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }*/
        else if(row == IGShowRowFavorite) {
            if([PHODFavoritesManager.sharedInstance showDateIsAFavorite:self.show.displayDate]) {
                [PHODFavoritesManager.sharedInstance removeFavoriteShowDate:self.show.displayDate];
            }
            else {
                [PHODFavoritesManager.sharedInstance addFavoriteShowDate:self.show.displayDate];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:IGShowSectionInfo]
                          withRowAnimation:UITableViewRowAnimationNone];
        }
        /*
        else if(row == IGShowRowDownloadAll) {
            for (NSObject<PHODGenericTrack> *track in self.show.tracks) {
                if(!track.isCached && track.isCacheable) {
                    [track.downloader downloadItem:track.downloadItem];
                }
            }
            
            [self.tableView reloadData];
        }
         */
        
        return;
    }
	   
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    NSArray *playlist = [self.show.tracks map:^id(IGTrack *track) {
        return [IguanaMediaItem.alloc initWithTrack:track
                                             inShow:self.show];
    }];
    
    [AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
    
    [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:indexPath.row];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
    
    [AppDelegate.sharedDelegate saveCurrentState];
}

- (NSArray *)getAllTracks {
    NSMutableArray *playlist = [NSMutableArray new];
    for (NSInteger i = 0; i < self.show.tracks.count; i++) {
        [playlist addObject:[IguanaMediaItem.alloc initWithTrack:self.show.tracks[i]
                                                          inShow:self.show]];
    }
    return playlist;
}

#pragma mark - Search results updater

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    self.searchTracks = self.show.tracks.mutableCopy;
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchText];
        [self.searchTracks filterUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

#pragma mark - Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.inSearchMode = NO;
    [searchBar resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        self.searchController.searchBar.alpha = 0;
    } completion:^(BOOL finished){
        self.tableView.tableHeaderView = nil;
        self.searchController.searchBar.alpha = 1;
        [self.tableView reloadData];
    }];
}

@end
