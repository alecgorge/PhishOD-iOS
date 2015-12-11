//
//  AGMediaPlayerViewController.m
//  iguana
//
//  Created by Alec Gorge on 3/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGMediaPlayerViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import <LastFm/LastFm.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>

#import "RLArtistTabViewController.h"
#import "PHODTabbedHomeViewController.h"
#import "IGDurationHelper.h"
#import "NowPlayingBarViewController.h"
#import "PhishTracksStats.h"
#import "PHODTrackCell.h"
#import "PhishinMediaItem.h"

#import "AppDelegate.h"
#import "IGEvents.h"
#import "IGThirdPartyKeys.h"
#import "IGAPIClient.h"
#import "IguanaMediaItem.h"

@interface AGMediaPlayerViewController () <AGAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *uiPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *uiPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *uiForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *uiBackwardButton;
@property (weak, nonatomic) IBOutlet UISlider *uiProgressSlider;
@property (weak, nonatomic) IBOutlet UILabel *uiTimeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiTimeElapsedLabel;
@property (weak, nonatomic) IBOutlet UIButton *uiLoopButton;
@property (weak, nonatomic) IBOutlet UIButton *uiShuffleButton;
@property (weak, nonatomic) IBOutlet UITableView *uiPlaybackQueueTable;
@property (weak, nonatomic) IBOutlet UILabel *uiStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *uiBottomBar;
@property (weak, nonatomic) IBOutlet UIView *uiTopBar;
@property (weak, nonatomic) IBOutlet MPVolumeView *uiVolumeView;

@property BOOL registeredAudioSession;

@property BOOL doneAppearance;
@property (nonatomic) NSTimeInterval shareTime;
@property (nonatomic) BOOL currentTrackHasBeenScrobbled;

@property (strong, nonatomic) CAGradientLayer *uiPlaybackQueueMask;

@property (nonatomic, assign) BOOL seeking;

- (IBAction)pressedPaused:(id)sender;
- (IBAction)pressedForward:(id)sender;
- (IBAction)pressedBackward:(id)sender;
- (IBAction)pressedLoop:(id)sender;
- (IBAction)pressedShuffle:(id)sender;
- (IBAction)pressedPlay:(id)sender;

@property (nonatomic) CSNNotificationObserver *headphoneObserver;

@end

@implementation AGMediaPlayerViewController

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithNibName:NSStringFromClass(AGMediaPlayerViewController.class)
                                                bundle:nil];
    });
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil
                               bundle:nibBundleOrNil]) {
        self.queue = [AGAudioPlayerUpNextQueue.alloc init];
        self.audioPlayer = [AGAudioPlayer.alloc initWithQueue:self.queue];
        self.audioPlayer.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.uiPlaybackQueueTable.estimatedRowHeight = 44;
    self.uiPlaybackQueueTable.rowHeight = UITableViewAutomaticDimension;
    [self.uiPlaybackQueueTable registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                                          bundle:nil]
                    forCellReuseIdentifier:@"track"];
    [self.uiPlaybackQueueTable setEditing:true animated:true];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(remoteControlReceivedWithEvent:)
												 name:@"RemoteControlEventReceived"
											   object:nil];
    
    [self setupAppearance];
    
    self.uiPlaybackQueueTable.allowsSelectionDuringEditing = YES;
}

- (void)audioPlayer:(AGAudioPlayer *)audioPlayer
uiNeedsRedrawForReason:(AGAudioPlayerRedrawReason)reason
          extraInfo:(NSDictionary *)dict {
    [self redrawUI];

    if(reason == AGAudioPlayerTrackProgressUpdated) {
        return;
    }
    
    [self setupBar];
    [self.uiPlaybackQueueTable reloadData];
    [self updateStatusBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AGMediaItemStateChanged"
                                                        object:self];
}

- (void)setupAppearance {
    [self setupBar];
    [self maskPlaybackQueue];
    [self updateStatusBar];
    
    self.view.backgroundColor = COLOR_PHISH_GREEN;
    
    self.uiTopBar.backgroundColor = COLOR_PHISH_GREEN;
    self.uiBottomBar.backgroundColor = COLOR_PHISH_GREEN;
    self.uiStatusLabel.backgroundColor = COLOR_PHISH_GREEN;
    
    self.uiProgressSlider.tintColor = COLOR_PHISH_WHITE;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.uiPlaybackQueueMask.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}

- (void)maskPlaybackQueue {
    for (UIView *slider in self.uiVolumeView.subviews) {
        if ([slider isKindOfClass:[UISlider class]]) {
            slider.tintColor = COLOR_PHISH_WHITE;
            ((UISlider*)slider).minimumTrackTintColor = COLOR_PHISH_WHITE;
        }
    }
}

- (void)redrawUICompletely {
    [self.uiPlaybackQueueTable reloadData];
    [self setupBar];
    [self redrawUI];
}

- (void)setupBar {
    static MarqueeLabel *label = nil;
    
    if(!label) {
        label = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)
                                               rate:10.0
                                      andFadeLength:10.0];

        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 1;
        label.font = [UIFont boldSystemFontOfSize: 14.0f];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.lineBreakMode = NSLineBreakByClipping;
        label.marqueeType = MLContinuous;
        
        self.navigationItem.titleView = label;
        
        [label restartLabel];
    }
    label.text = [NSString stringWithFormat:@"%@ — %@", self.currentItem.displayText, self.currentItem.displaySubtext];
    
    self.navigationController.navigationBar.barTintColor = COLOR_PHISH_GREEN;
	
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_halflings_113_chevron-down"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(share)];
}

- (void)share {
    if (IS_IPAD()) {
        [self shareFromView:(UIView*)self.navigationItem.leftBarButtonItem];
    }
    else {
        [self shareFromView:self.view];
    }
}

- (void)shareFromView:(UIView *)view {
    self.shareTime = self.progress * self.duration;
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Share with time?"
                                                               message:[NSString stringWithFormat:@"Do you want to include your current position in the song (%@) when you share this song?", [IGDurationHelper formattedTimeWithInterval:self.shareTime]]
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Share with time"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull action) {
                                            [self showShareSheetWithTime:YES];
                                        }]];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Share without time"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull action) {
                                            [self showShareSheetWithTime:NO];
                                        }]];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * _Nonnull action) {
                                            
                                        }]];
    
    [AppDelegate.sharedDelegate.tabs presentViewController:a
                                                  animated:YES
                                                completion:nil];
    [self.navigationController presentViewController:a
                                            animated:YES
                                          completion:nil];
}

- (float)duration {
    return self.audioPlayer.duration;
}

- (void)showShareSheetWithTime:(BOOL)time {
	if(!time) {
		self.shareTime = 0;
	}
    
    __block NSString *textToShare;
    void (^shareCb)(NSURL *) = ^(NSURL *urlToShare) {
        NSArray *itemsToShare;
        if(urlToShare) {
            itemsToShare = @[textToShare, urlToShare];
        }
        else {
            itemsToShare = @[textToShare];
        }
        
        IGEvent *e = [IGEvents startTimedEvent:@"share"];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
                                                                                 applicationActivities:nil];
        
        activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects: UIActivityTypePostToWeibo, nil];
        activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            [e endTimedEventWithAttributes:@{@"with_time": @(self.shareTime != 0).stringValue,
                                             @"activity_type": activityType ? activityType : @"",
                                             @"completed": @(completed).stringValue,
                                             @"content": [NSString stringWithFormat:@"%@__%@__%@__%ld", self.currentItem.artist, self.currentItem.album, self.currentItem.title, (long)self.currentItem.id],
                                             @"content_id": @(self.currentItem.id)
                                             }
                                andMetrics:@{@"completed": [NSNumber numberWithBool:completed],
                                             @"with_time": [NSNumber numberWithBool:self.shareTime != 0]}];
        };
        
        [AppDelegate.sharedDelegate.tabs presentViewController:activityVC
                                                      animated:YES
                                                    completion:nil];
        [self.navigationController presentViewController:activityVC
                                                animated:YES
                                              completion:nil];
    };
    
    [self.currentItem shareText:^(NSString *t) {
        textToShare = t;
        [self.currentItem shareURLWithTime:self.shareTime
                                  callback:shareCb];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(!self.doneAppearance) {
        [self setupAppearance];
        
        self.doneAppearance = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(NSNotification *)note {
    if(note == nil) return;
    
    UIEvent *event;
	if([note isKindOfClass:[UIEvent class]]) {
		event = (UIEvent*)note;
	}
	else {
		event = note.object;
	}
    
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self play];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pause];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayPause];
        }
        else if(event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self forward];
        }
        else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self backward];
        }
    }
}

#pragma mark - Public Interface

- (BOOL)playing {
    return self.audioPlayer.isPlaying;
}

- (BOOL)buffering {
    return self.audioPlayer.isBuffering;
}

- (id<AGAudioItem>)currentItem {
    return self.audioPlayer.currentItem;
}

- (NSInteger) nextIndex {
    return self.audioPlayer.nextIndex;
}

- (id<AGAudioItem>)nextItem {
    return self.audioPlayer.nextItem;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    NowPlayingBarViewController.sharedInstance.shouldShowBar = YES;
    
    [self.audioPlayer playItemAtIndex:currentIndex];
    
    self.currentTrackHasBeenScrobbled = NO;
    
    [LastFm.sharedInstance sendNowPlayingTrack:self.currentItem.title
									  byArtist:self.currentItem.artist
									   onAlbum:self.currentItem.album
								  withDuration:self.duration
								successHandler:nil
								failureHandler:nil];
    
#ifndef IS_PHISH
    IguanaMediaItem *item = (IguanaMediaItem *)self.currentItem;
    
    [IGAPIClient.sharedInstance playTrack:item.iguanaTrack
                                   inShow:item.iguanaShow];
#endif
    
    [self.uiPlaybackQueueTable reloadData];
    [self redrawUI];
}

- (NSInteger)currentIndex {
    return self.audioPlayer.currentIndex;
}

- (float)progress {
    if(self.duration == 0.0) {
        return 0;
    }
    
    return self.elapsed / self.duration;
}

- (NSTimeInterval)elapsed {
    return self.audioPlayer.elapsed;
}

- (void)setProgress:(float)progress {
    [self.audioPlayer seekToPercent:progress];
    self.uiProgressSlider.value = progress;
}

- (void)forward {
    [self.audioPlayer forward];
}

- (void)backward {
    [self.audioPlayer backward];
}

- (void)play {
    [self.audioPlayer resume];
}

- (void)pause {
    [self.audioPlayer pause];
}

- (void)stop {
    [self.audioPlayer stop];
    [self redrawUI];
}

- (void)togglePlayPause {
    if(!self.playing) {
        [self play];
    }
    else {
        [self pause];
    }
}

- (void)addItemsToQueue:(NSArray *)queue {
    [self.queue appendItems:queue];
    
    [self.uiPlaybackQueueTable reloadData];
}

- (void)insertItem:(id<AGAudioItem>)item atIndex:(NSUInteger)index {
    [self.queue insertItem:item atIndex:index];
    
    [self.uiPlaybackQueueTable reloadData];
}

- (void)replaceQueueWithItems:(NSArray *)queue startIndex:(NSInteger)index {
    [self.queue clearAndReplaceWithItems:queue];
    
    self.currentIndex = index;
    
	[self.uiPlaybackQueueTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index
																		 inSection:0]
									 atScrollPosition:UITableViewScrollPositionMiddle
											 animated:NO];
}

#pragma mark - Tableview Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.audioPlayer.queue moveItemAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    NSInteger diff = destinationIndexPath.row - sourceIndexPath.row;
    if (self.audioPlayer.currentIndex == sourceIndexPath.row) {
        [self.audioPlayer setIndex:self.audioPlayer.currentIndex + diff];
    } else {
        if (sourceIndexPath.row > self.audioPlayer.currentIndex && self.audioPlayer.currentIndex > destinationIndexPath.row) {
            [self.audioPlayer setIndex:self.audioPlayer.currentIndex - 1];
        } else if (sourceIndexPath.row < self.audioPlayer.currentIndex && self.audioPlayer.currentIndex < destinationIndexPath.row) {
            [self.audioPlayer setIndex:self.audioPlayer.currentIndex + 1];
        }
    }
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger currentIndex = self.audioPlayer.currentIndex;
        [self.queue removeItemAtIndex:indexPath.row];
        if (self.queue.count == 0) {
            [self.audioPlayer stop];
        } else if (indexPath.row == currentIndex) {
            if (self.queue.count <= currentIndex) {
                [self.audioPlayer playItemAtIndex:currentIndex - 1];
            } else {
                [self.audioPlayer playItemAtIndex:currentIndex];
            }
        }
        [tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"track";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    PHODTrackCell *c = (PHODTrackCell *)cell;
	[c showHeatmap:(!!self.heatmap)];
    [c updateCellWithTrack:[self.queue properQueueForShuffleEnabled:self.shuffle][indexPath.row]
            AndTrackNumber:indexPath.row + 1
               inTableView:tableView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    self.currentIndex = indexPath.row;
    
    // show correct playback indicator
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"];
    
    PHODTrackCell *c = (PHODTrackCell *)cell;
    return [c heightForCellWithTrack:[self.queue properQueueForShuffleEnabled:self.shuffle][indexPath.row]
                         inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.heatmap) {
		PHODTrackCell *pcell = (PHODTrackCell *)cell;
		PhishinMediaItem *mi = (PhishinMediaItem *) [pcell getTrack];
		PhishinTrack *track = (PhishinTrack *)mi.phishinTrack;
		float heatmapValue = [self.heatmap floatValueForKey:track.slug];
		[pcell updateHeatmapLabelWithValue:heatmapValue];
	}
}

#pragma mark - UI Stuff

- (void)updateStatusBar {
    if (self.buffering) {
        self.uiStatusLabel.hidden = NO;
        self.uiStatusLabel.text = @"Buffering";
    }
    else {
        self.uiStatusLabel.hidden = YES;
    }
}

#define STR_IF_NIL(x) (x?x:@"")

// no expensive calculations, just make UI is synced
- (void)redrawUI {
    self.uiPauseButton.hidden = !(self.playing || self.buffering);
    self.uiPlayButton.hidden = self.playing || self.buffering;
    
    self.uiBackwardButton.enabled = self.currentIndex != 0;
    self.uiForwardButton.enabled = self.currentIndex < self.queue.count;
    
    if(!self.seeking) {
        self.uiTimeElapsedLabel.text = [IGDurationHelper formattedTimeWithInterval:self.elapsed];
        self.uiProgressSlider.value = self.progress;
    }
    
    self.uiTimeLeftLabel.text = [IGDurationHelper formattedTimeWithInterval:self.duration];
    
	NSMutableDictionary *dict = @{
								  MPMediaItemPropertyAlbumTitle					: STR_IF_NIL(self.currentItem.album),
								  MPMediaItemPropertyTitle						: STR_IF_NIL(self.currentItem.title),
								  MPMediaItemPropertyAlbumTrackCount			: @(self.queue.count),
								  MPMediaItemPropertyArtist						: STR_IF_NIL(self.currentItem.artist),
								  MPNowPlayingInfoPropertyPlaybackQueueCount	: @(self.queue.count),
								  MPNowPlayingInfoPropertyPlaybackQueueIndex	: @(self.currentIndex),
								  MPNowPlayingInfoPropertyPlaybackRate			: @(self.playing ? 1.0 : 0),
								  MPNowPlayingInfoPropertyElapsedPlaybackTime	: @(self.elapsed)
								  }.mutableCopy;
	
	if(self.currentItem.artwork) {
		dict[MPMediaItemPropertyArtwork] = self.currentItem.artwork;
	}
    
    if(self.duration >= 0) {
        dict[MPMediaItemPropertyPlaybackDuration] = @(self.duration);
    }
	
    [MPNowPlayingInfoCenter.defaultCenter setNowPlayingInfo:dict];
    
    if ((NSInteger)self.elapsed % 5 == 0 && self.elapsed > 0.0f) {
        [AppDelegate.sharedDelegate saveCurrentState];
    }
    
	if(!self.currentTrackHasBeenScrobbled && self.progress > .5) {
        if (IGThirdPartyKeys.sharedInstance.isLastFmEnabled) {
            [[LastFm sharedInstance] sendScrobbledTrack:self.currentItem.title
                                               byArtist:self.currentItem.artist
                                                onAlbum:self.currentItem.album
                                           withDuration:self.duration
                                            atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
                                         successHandler:nil
                                         failureHandler:nil];
        }
        
        NSObject<AGAudioItem> *obj = (NSObject<AGAudioItem> *)self.currentItem;
        
        [IGEvents trackEvent:@"played_track"
              withAttributes:@{@"provider": NSStringFromClass(obj.class),
                               @"title": self.currentItem.title,
                               @"album": self.currentItem.album,
                               @"is_cached_attr": @(self.currentItem.isCached).stringValue,
                               @"artist": self.currentItem.artist,
                               @"id": @(self.currentItem.id),
                               @"duration": [NSNumber numberWithFloat:self.duration],
                               }
                  andMetrics:@{@"duration": [NSNumber numberWithFloat:self.duration],
                               @"is_cached": [NSNumber numberWithBool:self.currentItem.isCached]}];
        
		self.currentTrackHasBeenScrobbled = YES;
		
		if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
			if([obj.class isKindOfClass:PhishinMediaItem.class]) {
				PhishinTrack *track = ((PhishinMediaItem*)self.currentItem).phishinTrack;
				[PhishTracksStats.sharedInstance createPlayedTrack:track
														   success:nil
														   failure:^(PhishTracksStatsError *error) {
															   if (error) {
																   [FailureHandler showAlertWithStatsError:error];
															   }
														   }];
			}
		}
    }
}

- (IBAction)pressedPaused:(id)sender {
    [self pause];
}

- (IBAction)pressedForward:(id)sender {
    [self forward];
}

- (IBAction)pressedBackward:(id)sender {
    [self backward];
}

- (IBAction)pressedLoop:(id)sender {
    self.loop = !self.loop;
}

- (IBAction)pressedShuffle:(id)sender {
    self.shuffle = !self.shuffle;
}

- (IBAction)pressedPlay:(id)sender {
    [self play];
}

- (IBAction)seekingStarted:(id)sender {
    self.seeking = YES;
}

- (IBAction)seekingEndedOutside:(id)sender {
    self.seeking = NO;
    self.progress = self.uiProgressSlider.value;
}

- (IBAction)seekingEndedInside:(id)sender {
    [self seekingEndedOutside:sender];
}

- (IBAction)seekingValueChanged:(id)sender {
    if(self.seeking) {
        self.uiTimeElapsedLabel.text = [IGDurationHelper formattedTimeWithInterval:self.uiProgressSlider.value * self.duration];
    }
}

@end
