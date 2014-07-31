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

#import "AppDelegate.h"
#import "SongInstancesViewController.h"
#import "AGMediaPlayerViewController.h"
#import "VenueViewController.h"
#import "PhishinMediaItem.h"
#import "PHODTrackCell.h"

#import "PhishTracksStatsFavoritePopover.h"
#import "ShowHeaderView.h"
#import "ShowDetailsViewController.h"

@interface ShowViewController ()

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;
@property (nonatomic) ShowDetailsViewController *detailsVc;

@end

@implementation ShowViewController

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

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupRightBarButtonItem];
	[self setupTableView];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
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
}

- (void)setupRightBarButtonItem {
    UIImage *customImage = [UIImage heartIconWhite];
    UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithImage:customImage
                                                                            style:UIBarButtonItemStyleBordered
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
										[self.tableView reloadData];
										
										if(self.detailsVc) {
											[self.detailsVc.tableView reloadData];
										}
									}
									failure:REQUEST_FAILED(self.tableView)];
	[[PhishinAPI sharedAPI] fullShow:self.show
							 success:^(PhishinShow *ss) {
								 self.show = ss;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.show ? self.show.sets.count : 1;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.show && self.show.sets.count > 0) {
		return ((PhishinSet*)self.show.sets[section]).tracks.count;
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
		
		[h updateCellForShow:self.show
				 withSetlist:self.setlist
				 inTableView:tableView];
		
		return h;
	}
	
    return nil;
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"
                                                          forIndexPath:indexPath];
	
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
    
    [cell updateCellWithTrack:track
                  inTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    }
    
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"];
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
    
    return [cell heightForCellWithTrack:track
                            inTableView:tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
	PhishinSong *song = [[PhishinSong alloc] init];
	song.id = [track.song_ids[0] integerValue];
	
	[self.navigationController pushViewController:[[SongInstancesViewController alloc] initWithSong:song]
										 animated:YES];	
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
    
	[self playTrack:track];
}

- (void)playTrack:(PhishinTrack *)track {
	NSArray *playlist = [self.show.tracks map:^id(id object) {
		return [PhishinMediaItem.alloc initWithTrack:object];
	}];
	
	NSInteger startIndex = [self.show.tracks indexOfObjectPassingTest:^BOOL(PhishinTrack *obj, NSUInteger idx, BOOL *stop) {
		return track.id == [obj id];
	}];
	
	[AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
	
    if(!AGMediaPlayerViewController.sharedInstance.playbackQueue
	|| AGMediaPlayerViewController.sharedInstance.playbackQueue.count == 0) {
        [AppDelegate.sharedDelegate presentMusicPlayer];
    }

    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:startIndex];
}

@end
