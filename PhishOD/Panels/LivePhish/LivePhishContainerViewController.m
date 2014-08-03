//
//  LivePhishContainerViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishContainerViewController.h"

#import <SDWebImage/SDWebImageManager.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>
#import <SVWebViewController/SVWebViewController.h>
#import "MEExpandableHeaderView.h"

#import "NowPlayingBarViewController.h"
#import "AGMediaPlayerViewController.h"
#import "IGDurationHelper.h"
#import "LivePhishAPI.h"
#import "PHODTrackCell.h"
#import "LivePhishMediaItem.h"
#import "AppDelegate.h"
#import "LivePhishNotesViewController.h"
#import "LivePhishReviewsViewController.h"

typedef NS_ENUM(NSInteger, LivePhishContainerViewSections) {
    LivePhishContainerViewInfoSection,
    LivePhishContainerViewSectionCount,
};

typedef NS_ENUM(NSInteger, LivePhishContainerViewInfoRows) {
    LivePhishContainerViewInfoNotesRow,
    LivePhishContainerViewInfoReviewsRow,
    LivePhishContainerViewInfoViewOnlineRow,
    LivePhishContainerViewInfoCanStreamRow,
    LivePhishContainerViewInfoRowCount,
};

@interface LivePhishContainerViewController ()

@property (nonatomic) LivePhishContainer *container;
@property (nonatomic) LivePhishCompleteContainer *completeContainer;

@property (nonatomic) NSArray *headerPages;
@property (nonatomic) MEExpandableHeaderView *headerView;

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;

@property (nonatomic) BOOL loadedFromCompleteContainer;

@end

@implementation LivePhishContainerViewController

- (instancetype)initWithContainer:(LivePhishContainer *)container {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.container = container;
    }
    
    return self;
}

- (instancetype)initWithCompleteContainer:(LivePhishCompleteContainer *)completeContainer {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.container = self.completeContainer = completeContainer;
        self.loadedFromCompleteContainer = YES;
        
        [self setupTableHeaderWithImage:[UIImage imageNamed:@"stock_header_chris_tank.jpg"]];
        [self downloadAlbumArt];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.container.displayText;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"track"];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [self.tableView reloadData];
                                                                }];
    
	[AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		[self.tableView reloadData];
	}];
}

- (void)refresh:(id)sender {
    if(self.loadedFromCompleteContainer) {
        [super refresh:sender];
        return;
    }
    
    [LivePhishAPI.sharedInstance completeContainerForContainer:self.container
                                                       success:^(LivePhishCompleteContainer *container) {
                                                           self.completeContainer = container;
                                                           
                                                           [self setupTableHeaderWithImage:[UIImage imageNamed:@"stock_header_chris_tank.jpg"]];
                                                           [self downloadAlbumArt];
                                                           
                                                           [self.tableView reloadData];
                                                           [super refresh:sender];
                                                           
                                                           [self.refreshControl removeFromSuperview];
                                                       }
                                                       failure:REQUEST_FAILED(self.tableView)];
}

#pragma mark - Stretchy header

- (void)setupTableHeaderWithImage:(UIImage *)backgroundImage {
    self.tableView.tableHeaderView = nil;
    CGSize headerViewSize = CGSizeMake(self.tableView.bounds.size.width, 200);
    
    NSArray *pages = @[[self createPageViewWithText:self.completeContainer.displayText],
                       [self createPageViewWithText:self.completeContainer.displaySubtext],
                       [self createPageViewWithText:[IGDurationHelper formattedTimeWithInterval: self.completeContainer.runningTime]],
                       ];
    
    MEExpandableHeaderView *headerView = [[MEExpandableHeaderView alloc] initWithSize:headerViewSize
                                                                      backgroundImage:backgroundImage
                                                                         contentPages:pages];
    
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)downloadAlbumArt {
    [SDWebImageManager.sharedManager downloadImageWithURL:self.completeContainer.imageURL
                                                  options:0
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                     
                                                 }
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                    if(error) {
                                                        dbug(@"image error: %@", error);
                                                    }
                                                    else {
														self.completeContainer.image = image;
                                                        [self setupTableHeaderWithImage:image];
                                                        [self.tableView reloadData];
                                                    }
                                                }];
}

- (UIView*)createPageViewWithText:(NSString*)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width - 24.0f, 180)];
    
    label.font = [UIFont boldSystemFontOfSize:27.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.50];
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.numberOfLines = 0;
    label.layer.cornerRadius = 7.0f;
    
    label.text = text;
    
    [label sizeToFit];
    
    CGRect f = label.frame;
    f.size.width += 15;
    f.size.height += 10;
    
    label.frame = f;
    
    label.layer.cornerRadius = 5.0f;
label.layer.masksToBounds = YES;
    
    return label;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.tableView) {
        [self.headerView offsetDidUpdate:scrollView.contentOffset];
    }
}

- (NSArray *)allTracks {
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
		return [self.completeContainer.songs reject:^BOOL(LivePhishSong *tr) {
			return !tr.isCached;
		}];
	}
	
	return self.completeContainer.songs;
}

#pragma mark - Table view data source

- (LivePhishSong *)songForIndexPath:(NSIndexPath *)indexPath {
    LivePhishSet *set = self.completeContainer.sets[indexPath.section - 1];
    return set.songs[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return LivePhishContainerViewSectionCount + self.completeContainer.sets.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if(section == LivePhishContainerViewInfoSection) {
        return LivePhishContainerViewInfoRowCount;
    }
    else {
        LivePhishSet *set = self.completeContainer.sets[section - 1];
        return set.songs.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == LivePhishContainerViewInfoSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
        
        if(!cell) {
            cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:@"value1"];
        }
        
        if(indexPath.row == LivePhishContainerViewInfoNotesRow) {
            cell.textLabel.text = @"Notes";
            cell.detailTextLabel.text = @(self.completeContainer.notes.count).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == LivePhishContainerViewInfoReviewsRow) {
            cell.textLabel.text = @"Reviews";
            cell.detailTextLabel.text = @(self.completeContainer.reviews.count).stringValue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == LivePhishContainerViewInfoViewOnlineRow) {
            cell.textLabel.text = @"View/buy on LivePhish.com";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.row == LivePhishContainerViewInfoCanStreamRow) {
            cell.textLabel.text = @"Can I stream this?";
            cell.detailTextLabel.text = self.completeContainer.canStream ? @"Yes" : @"No";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        LivePhishSong *song = [self songForIndexPath:indexPath];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"track"
                                               forIndexPath:indexPath];
        
        PHODTrackCell *tc = (PHODTrackCell *)cell;
        [tc updateCellWithTrack:song
                    inTableView:tableView];
        
        if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
            tc.selectionStyle = self.completeContainer.canStream ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LivePhishContainerViewInfoSection) {
        return UITableViewAutomaticDimension;
    }
    
    LivePhishSong *song = [self songForIndexPath:indexPath];
    
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"];
    
    return [cell heightForCellWithTrack:song
                            inTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == LivePhishContainerViewInfoSection) {
        return nil;
    }

    LivePhishSet *set = self.completeContainer.sets[section - 1];
    return set.name;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    LivePhishSong *song = [self songForIndexPath:indexPath];
    return song.isCached;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LivePhishSong *song = [self songForIndexPath:indexPath];
        [song.downloadItem delete];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if(indexPath.section == LivePhishContainerViewInfoSection) {
        if(indexPath.row == LivePhishContainerViewInfoNotesRow) {
            LivePhishNotesViewController *vc = [LivePhishNotesViewController.alloc initWithCompleteContainer:self.completeContainer];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        else if(indexPath.row == LivePhishContainerViewInfoReviewsRow) {
            LivePhishReviewsViewController *vc = [LivePhishReviewsViewController.alloc initWithCompleteContainer:self.completeContainer];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        else if(indexPath.row == LivePhishContainerViewInfoViewOnlineRow) {
            SVWebViewController *vc = [SVWebViewController.alloc initWithURL:self.completeContainer.livePhishPageURL];
            [self.navigationController pushViewController:vc
                                                 animated:YES];
        }
        else if(indexPath.row == LivePhishContainerViewInfoCanStreamRow) {
        }
        
        return;
    }
    
    if(!self.completeContainer.canStream) {
        return;
    }
    
    LivePhishSong *song = [self songForIndexPath:indexPath];
    
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable
    && !song.isCached) {
		return;
	}
    
    __block NSInteger row = 0;
    __block NSInteger i = 0;
    NSArray *trks = [[self allTracks] map:^id(LivePhishSong *item) {
        if (song.id == item.id) {
            row = i;
        }
        
        i++;
        return [[LivePhishMediaItem alloc] initWithSong:item
                                   andCompleteContainer:self.completeContainer];
    }];
    
    if(!NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        [AppDelegate.sharedDelegate presentMusicPlayer];
    }
    
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:trks
                                                           startIndex:row];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
}

@end
