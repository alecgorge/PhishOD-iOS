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

#import "PHODTrackCell.h"

NS_ENUM(NSInteger, IGShowSections) {
    IGShowSectionInfo,
    IGShowSectionTracks,
    IGShowSectionCount,
};

NS_ENUM(NSInteger, IGShowRows) {
    IGShowRowSource,
    IGShowRowReviews,
    IGShowRowVenue,
    IGShowRowFavorite,
//    IGShowRowDownloadAll,
    IGShowRowCount
};

@interface RLShowViewController ()

@property (nonatomic, strong) IGShow *show;
@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;

@end

@implementation RLShowViewController

- (instancetype)initWithShow:(IGShow *)show {
    if(self = [super initWithStyle:UITableViewStylePlain]) {
        self.show = show;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.show.displayDate;
    
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
        return IGShowRowCount;
    }
    
    return self.show.tracks.count;
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
        else if(indexPath.row == IGShowRowReviews) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plain"];
            
            if (!cell) {
                cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:@"plain"];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"Read %lu reviews", self.show.reviews.count];
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
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", self.show.venue.name, self.show.venue.city];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
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
        
        IGTrack *track = self.show.tracks[indexPath.row];
        
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
        if(row == IGShowRowReviews) {
            RLShowReviewsViewController *vc = [RLShowReviewsViewController.alloc initWithShow:self.show];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        else if(row == IGShowRowVenue) {
            RLShowCollectionViewController *vc = [RLShowCollectionViewController.alloc initWithVenue:self.show.venue];
            
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
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
    
    NSArray *playlist = [self.show.tracks map:^id(id object) {
        return [IguanaMediaItem.alloc initWithTrack:object
                                             inShow:self.show];
    }];
    
    [AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
    
    [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:indexPath.row];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
    
    [AppDelegate.sharedDelegate saveCurrentState];
}

@end
