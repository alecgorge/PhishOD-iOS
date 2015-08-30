//
//  ShowViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ShowViewController.h"

#import <SVWebViewController/SVWebViewController.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

#import "AppDelegate.h"
#import "NowPlayingBarViewController.h"
#import "SongInstancesViewController.h"
#import "AGMediaPlayerViewController.h"
#import "VenueViewController.h"
#import "PhishinMediaItem.h"
#import "PHODTrackCell.h"

#import "PhishTracksStats.h"
#import "PhishTracksStatsFavoritePopover.h"
#import "PTSHeatmapQuery.h"
#import "PTSHeatmap.h"
#import "ShowHeaderView.h"
#import "ShowDetailsViewController.h"

@interface ShowViewController ()

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;
@property (nonatomic) ShowDetailsViewController *detailsVc;

@property (nonatomic) BOOL loadedFromCompleteShow;

@end

@implementation ShowViewController {
	PTSHeatmap *_showHeatmap;
}

- (id)initWithShow:(PhishinShow*)s {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.show = s;
		self.title = self.show.date;
		
		self.autoplay = NO;
		self.autoplaySeekLocation = 0.0;
    }
    return self;
}

- (id)initWithShowDate:(NSString *)showDate {
	PhishinShow *__show = [[PhishinShow alloc] init];
	__show.date = showDate;
	return [self initWithShow:__show];
}

- (instancetype)initWithCompleteShow:(PhishinShow *)completeShow {
	self = [self initWithShow:completeShow];
	
	self.setlist = completeShow.setlist;
	self.loadedFromCompleteShow = YES;
	
	return self;
}

- (void)viewDidLoad {
	// super viewDidLoad triggers the refresh
	if(self.loadedFromCompleteShow) {
        self.preventRefresh = YES;
	}
    
	[super viewDidLoad];
	
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;

    [self setupRightBarButtonItem];
	[self setupTableView];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [self.tableView reloadData];
                                                                }];
	
	[AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		[self.tableView reloadData];
	}];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"track"];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ShowHeaderView.class)
											   bundle:NSBundle.mainBundle]
forHeaderFooterViewReuseIdentifier:@"showHeader"];
	
	CGRect frame = self.tableView.bounds;
	
	frame.origin.y = -frame.size.height;
	UIView* grayView = [UIView.alloc initWithFrame:frame];
	grayView.backgroundColor = [UIColor colorWithWhite:0.975 alpha:1.000];
	
	self.tableView.backgroundView = grayView;
	
	self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)setupRightBarButtonItem {
    UIImage *customImage = [UIImage heartIconWhite];
    UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithImage:customImage
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(favoriteTapped:)];
    
    self.navigationItem.rightBarButtonItem = customBarButtonItem;
}

- (void)favoriteTapped:(id)sender {
    [PhishTracksStatsFavoritePopover.sharedInstance showFromBarButtonItem:sender
                                                                   inView:self.view
                                                        withPhishinObject:self.show];
}

- (void)refresh:(id)sender {
	self.setlist = nil;
	[[PhishNetAPI sharedAPI] setlistForDate:self.show.date
									success:^(PhishNetSetlist *s) {
										self.setlist = s;
										if(self.show && !self.show.setlist) {
											self.show.setlist = s;
											[self.show cache];
										}
										
										[self.tableView reloadData];
										
										if(self.detailsVc) {
											[self.detailsVc.tableView reloadData];
										}
									}
									failure:REQUEST_FAILED(self.tableView)];
	
	[[PhishinAPI sharedAPI] fullShow:self.show
							 success:^(PhishinShow *ss) {
								 self.show = ss;
								 if(self.setlist && !self.show.setlist) {
									 self.show.setlist = self.setlist;
									 [self.show cache];
								 }
								 
								 [self.tableView reloadData];
								 
								 if(self.detailsVc) {
									 [self.detailsVc.tableView reloadData];
								 }
								 
								 if(self.show.missing) {
									 UIAlertView *a = [UIAlertView.alloc initWithTitle:@"Recording Missing"
																			   message:@"Unfortunately, we don't have a recording for this show :(. If you think you have a recording that should be up here please contact phish.in.music@gmail.com"
																			  delegate:nil
																	 cancelButtonTitle:@"OK :("
																	 otherButtonTitles:nil];
									 
									 [a show];
								 }
								 
								 [super refresh:sender];
								 [self performAutoplayIfNecessary];
							 } failure:REQUEST_FAILED(self.tableView)];
	
	[self refreshHeatmap];
}

- (void)refreshHeatmap {
	PTSHeatmapQuery *query = [[PTSHeatmapQuery alloc] initWithAutoTimeframeAndEntity:@"show" filter:self.show.date];
	
	[PhishTracksStats.sharedInstance globalHeatmapWithQuery:query
        success:^(PTSHeatmap *results) {
			_showHeatmap = results;
			[self.tableView reloadData];
    	}
        failure:nil//^(PhishTracksStatsError *err) {
    	];
}

- (void)performAutoplayIfNecessary {
	if(self.autoplay && self.show.tracks) {
		NSArray *matchingTracks = [self.show.tracks reject:^BOOL(PhishinTrack *object) {
			return !(object.id == self.autoplayTrackId);
		}];
		
		if(matchingTracks.count > 0) {
			PhishinTrack *track = matchingTracks[0];
			
			[self playTrack:track];
            

			if(self.autoplaySeekLocation > 0) {
				[self performSelector:@selector(autoplaySeek)
						   withObject:nil
						   afterDelay:0.25];
			}
		}
		
		self.autoplay = NO;
	}
}

- (void)autoplaySeek {
	if(AGMediaPlayerViewController.sharedInstance.progress > 0) {
		AGMediaPlayerViewController.sharedInstance.progress = self.autoplaySeekLocation / AGMediaPlayerViewController.sharedInstance.duration;
	}
	else {
		[self performSelector:@selector(autoplaySeek)
				   withObject:nil
				   afterDelay:0.25];
	}
}

- (NSArray *)tracksForSections:(NSInteger) section {
	PhishinSet *set = self.show.sets[section];
	
//	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
//		return [set.tracks reject:^BOOL(PhishinTrack *tr) {
//			return !tr.isCached;
//		}];
//	}
	
	return set.tracks;
}

- (NSArray *)allTracks {
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
		return [self.show.tracks reject:^BOOL(PhishinTrack *tr) {
			return !tr.isCached;
		}];
	}
	
	return self.show.tracks;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.show ? self.show.sets.count : 1;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.show && self.show.sets.count > 0) {
		return [self tracksForSections:section].count;
	}

	return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Show Info";
	}
	return self.show.sets.count > 0 ? ((PhishinSet*)self.show.sets[section]).title : nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [ShowHeaderView cellHeightForShow:self.show
									 inTableView:tableView];
	}
	
	return tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        ShowHeaderView *h = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"showHeader"];
		
		h.headerTapped = ^{
			if(!self.show && !self.setlist) {
				// we need one thing loaded first
				return;
			}
			
			self.detailsVc = [ShowDetailsViewController.alloc initWithShowViewController:self];
			[self.navigationController pushViewController:self.detailsVc
												 animated:YES];
		};
        
        h.downloadAllTapped = ^{
            if(!self.show && !self.setlist) {
                // we need one thing loaded first
                return;
            }

            for (NSObject<PHODGenericTrack> *track in self.show.tracks) {
                if(!track.isCached && track.isCacheable) {
                    [track.downloader downloadItem:track.downloadItem];
                }
            }
            
            [self.tableView reloadData];
        };
		
		[h updateCellForShow:self.show
				 withSetlist:self.setlist
				 inTableView:tableView];
		
		return h;
	}
	
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"
                                                          forIndexPath:indexPath];
	
	PhishinTrack *track = [self tracksForSections:indexPath.section][indexPath.row];
	
    [cell updateCellWithTrack:track
                  inTableView:tableView];
	
	float heatmapValue = [_showHeatmap floatValueForKey:track.slug];
	[cell updateHeatmapLabelWithValue:heatmapValue];
	
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView
//heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"];
//	PhishinTrack *track = [self tracksForSections:indexPath.section][indexPath.row];
//    
//    return [cell heightForCellWithTrack:track
//                            inTableView:tableView];
//}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishinTrack *track = [self tracksForSections:indexPath.section][indexPath.row];
    return track.isCached;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PhishinTrack *track = [self tracksForSections:indexPath.section][indexPath.row];
        [track.downloadItem delete];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishinTrack *track = [self tracksForSections:indexPath.section][indexPath.row];
	
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable
	&& !track.isCached) {
		return;
	}
	
	[self playTrack:track];
}

- (void)playTrack:(PhishinTrack *)track {
	NSArray *tracks = [self allTracks];
	
	NSArray *playlist = [tracks map:^id(id object) {
		return [PhishinMediaItem.alloc initWithTrack:object
											  inShow:self.show];
	}];
	
	NSInteger startIndex = [tracks indexOfObjectPassingTest:^BOOL(PhishinTrack *obj, NSUInteger idx, BOOL *stop) {
		return track.id == [obj id];
	}];
	
	[AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
	
//    if(!NowPlayingBarViewController.sharedInstance.shouldShowBar) {
//        [AppDelegate.sharedDelegate presentMusicPlayer];
//    }

    [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
	AGMediaPlayerViewController.sharedInstance.heatmap = _showHeatmap;
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:startIndex];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
    
    [AppDelegate.sharedDelegate saveCurrentState];
}

@end
