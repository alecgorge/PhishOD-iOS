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

#import <FreeStreamer/FSPlaylistItem.h>

#import <LastFm/LastFm.h>
#import <MarqueeLabel/MarqueeLabel.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>

#import "IGDurationHelper.h"
#import "NowPlayingBarViewController.h"
#import "PhishTracksStats.h"
#import "PHODTrackCell.h"
#import "PhishinMediaItem.h"

#import "AppDelegate.h"
#import "IGEvents.h"
#import "IGThirdPartyKeys.h"

@interface FSAudioController ()

@property (nonatomic,assign) NSUInteger currentPlaylistItemIndex;

@end

@interface AGMediaPlayerViewController ()

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
        self.playbackQueue = [NSMutableArray array];
        
        self.audioController = FSAudioController.new;
        self.audioController.delegate = self;
        
        self.audioController.enableDebugOutput = YES;
        
        __weak AGMediaPlayerViewController *s = self;
        self.audioController.onFailure = ^(FSAudioStreamError error , NSString *errorDescription) {
            NSLog(@"[audioPlayer] error: %d, %@", error, errorDescription);
            
            [s updateStatusBar];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AGMediaItemStateChanged"
                                                                object:s];
            
            [s.uiPlaybackQueueTable reloadData];
            
            [s setupBar];
        };
        
        self.audioController.onStateChange = ^(FSAudioStreamState state) {
            NSLog(@"[audioPlayer] changed to state: %@", [self stringForStatus:state]);
            s.state = state;
            [s updateStatusBar];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AGMediaItemStateChanged"
                                                                object:s];
            
            [s.uiPlaybackQueueTable reloadData];
            
            [s setupBar];
            [self registerAudioSession];
        };
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(remoteControlReceivedWithEvent:)
												 name:@"RemoteControlEventReceived"
											   object:nil];
    
    [self setupAppearance];
    [self startUpdates];
}

- (void)startUpdates {
    [self redrawUI];
    
    [self performSelector:@selector(startUpdates)
               withObject:nil
               afterDelay:0.5];
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
    label.text = [NSString stringWithFormat:@"%@ — %@", self.currentItem.displayText, self.currentItem.displaySubText];
    
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
    self.shareTime = self.progress;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to include your current position in the song (%@) when you share this song?", [IGDurationHelper formattedTimeWithInterval:self.shareTime]]
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Share with time", @"Share without time", nil];
    
    if(IS_IPAD()) {
        [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem
                                  animated:YES];
    }
    else {
        [actionSheet showInView:self.view];
    }
}

- (float)duration {
    if(self.audioController.activeStream.duration.playbackTimeInSeconds != 0) {
        return self.audioController.activeStream.duration.playbackTimeInSeconds;
    }
    
    return self.currentItem.duration;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 2) return;
    
	if(buttonIndex == 1) {
		self.shareTime = 0;
	}
    
	NSString *textToShare = self.currentItem.shareText;
	NSURL *urlToShare = [self.currentItem shareURLWithTime:self.shareTime];
    
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
                                         @"completed": @(completed).stringValue
                                         }
                            andMetrics:@{@"completed": [NSNumber numberWithBool:completed],
                                         @"with_time": [NSNumber numberWithBool:self.shareTime != 0]}];
    };
    
	[self.navigationController presentViewController:activityVC
											animated:YES
										  completion:nil];
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
    return self.state == kFsAudioStreamPlaying || self.state == kFsAudioStreamSeeking;
}

- (BOOL)buffering {
    return self.state == kFsAudioStreamBuffering || self.state == kFsAudioStreamRetryingStarted;
}

- (AGMediaItem *)currentItem {
    if (self.currentIndex >= self.playbackQueue.count) {
        return nil;
    }
    
    return self.playbackQueue[self.currentIndex];
}

- (NSInteger) nextIndex {
    if(self.loop) {
        return self.currentIndex;
    }
    else if(self.shuffle) {
        NSInteger randomIndex = -1;
        while(randomIndex == -1 || randomIndex == self.currentIndex)
            randomIndex = arc4random_uniform((u_int32_t)self.playbackQueue.count);
        return randomIndex;
    }
    else if(self.playbackQueue.count == 1) {
        return -1;
    }
    
    if(self.currentIndex + 1 >= self.playbackQueue.count) {
        return 0;
    }
    
    return self.currentIndex + 1;
}

- (AGMediaItem *)nextItem {
    if(self.nextIndex >= self.playbackQueue.count) {
        return nil;
    }
    
    return self.playbackQueue[self.nextIndex];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    NowPlayingBarViewController.sharedInstance.shouldShowBar = YES;
    
    [self.audioController playItemAtIndex:currentIndex];
    
    self.currentTrackHasBeenScrobbled = NO;
    
    [LastFm.sharedInstance sendNowPlayingTrack:self.currentItem.title
									  byArtist:self.currentItem.artist
									   onAlbum:self.currentItem.album
								  withDuration:self.duration
								successHandler:nil
								failureHandler:nil];
    
    [self.uiPlaybackQueueTable reloadData];
    [self redrawUI];
}

- (NSInteger)currentIndex {
    return self.audioController.currentPlaylistItemIndex;
}

- (float)progress {
    if(self.duration == 0.0) {
        return 0;
    }
    
    return self.elapsed / self.duration;
}

- (NSTimeInterval)elapsed {
    return self.audioController.activeStream.currentTimePlayed.playbackTimeInSeconds;
}

- (void)setProgress:(float)progress {
    FSStreamPosition pos;
    
    pos.position = progress;
    
    [self.audioController.activeStream seekToPosition:pos];
    self.uiProgressSlider.value = progress;
}

- (void)forward {
    [self.audioController playNextItem];
}

- (void)backward {
    if(self.elapsed < 10) {
        [self.audioController playPreviousItem];
    }
    else {
        self.progress = 0.0;
    }
}

- (void)play {
    if(self.state == kFsAudioStreamPaused) {
        [self.audioController pause];
    }
    else {
        [self.audioController play];
    }
    [self redrawUI];
}

- (void)pause {
    [self.audioController pause];
    [self redrawUI];
}

- (void)stop {
    [self.audioController stop];
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
    [self.playbackQueue addObjectsFromArray:queue];
}

- (void)replaceQueueWithItems:(NSArray *)queue startIndex:(NSInteger)index {
    self.playbackQueue = [queue mutableCopy];
    
    [self.audioController playFromPlaylist:[self.playbackQueue map:^id(AGMediaItem *object) {
        FSPlaylistItem *i = FSPlaylistItem.new;
        
        i.url = object.playbackURL;
        i.title = object.displayText;
        
        return i;
    }]];
    
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
    return self.playbackQueue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"track";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    PHODTrackCell *c = (PHODTrackCell *)cell;
	[c showHeatmap:(!!self.heatmap)];
    [c updateCellWithTrack:self.playbackQueue[indexPath.row]
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
    return [c heightForCellWithTrack:self.playbackQueue[indexPath.row]
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

- (NSString *)stringForStatus:(FSAudioStreamState)status {
    switch (status) {
        case kFsAudioStreamRetrievingURL:
            return @"Retrieving URL";
        case kFsAudioStreamStopped:
            return @"Stopped";
        case kFsAudioStreamBuffering:
            return @"Buffering";
        case kFsAudioStreamPlaying:
            return @"Playing";
        case kFsAudioStreamPaused:
            return @"Paused";
        case kFsAudioStreamSeeking:
            return @"Seeking";
        case kFSAudioStreamEndOfFile:
            return @"Got Stream EOF";
        case kFsAudioStreamFailed:
            return @"Stream Failed";
        case kFsAudioStreamRetryingStarted:
            return @"Stream Retrying: Started";
        case kFsAudioStreamRetryingSucceeded:
            return @"Stream Retrying: Success";
        case kFsAudioStreamRetryingFailed:
            return @"Stream Retrying: Failed";
        case kFsAudioStreamPlaybackCompleted:
            return @"Playback Complete";
        case kFsAudioStreamUnknownState:
            return @"Unknown!?";
    }
}

- (NSString *)stringForErrorCode:(FSAudioStreamError)status {
    switch (status) {
        case kFsAudioStreamErrorNone:
            return @"No Error";
        case kFsAudioStreamErrorOpen:
            return @"Error: open";
        case kFsAudioStreamErrorStreamParse:
            return @"Error: stream parse";
        case kFsAudioStreamErrorNetwork:
            return @"Error: network";
        case kFsAudioStreamErrorUnsupportedFormat:
            return @"Error: unsupported format";
        case kFsAudioStreamErrorStreamBouncing:
            return @"Error: stream bouncing";
    }
}

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
    self.uiForwardButton.enabled = self.currentIndex < self.playbackQueue.count;
    
    self.uiTimeElapsedLabel.text = [IGDurationHelper formattedTimeWithInterval:self.elapsed];
    self.uiTimeLeftLabel.text = [IGDurationHelper formattedTimeWithInterval:self.duration];
    
    self.uiProgressSlider.value = self.progress;
    
	NSMutableDictionary *dict = @{
								  MPMediaItemPropertyAlbumTitle					: STR_IF_NIL(self.currentItem.album),
								  MPMediaItemPropertyTitle						: STR_IF_NIL(self.currentItem.title),
								  MPMediaItemPropertyAlbumTrackCount			: @(self.playbackQueue.count),
								  MPMediaItemPropertyArtist						: STR_IF_NIL(self.currentItem.artist),
								  MPNowPlayingInfoPropertyPlaybackQueueCount	: @(self.playbackQueue.count),
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
        
        [IGEvents trackEvent:@"played_track"
              withAttributes:@{@"provider": NSStringFromClass(self.currentItem.class),
                               @"title": self.currentItem.title,
                               @"album": self.currentItem.album,
                               @"is_cached_attr": @(self.currentItem.isCached).stringValue,
                               @"artist": self.currentItem.artist}
                  andMetrics:@{@"duration": [NSNumber numberWithFloat:self.duration],
                               @"is_cached": [NSNumber numberWithBool:self.currentItem.isCached]}];
        
		self.currentTrackHasBeenScrobbled = YES;
		
		if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
			if([self.currentItem isKindOfClass:PhishinMediaItem.class]) {
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

#pragma mark - Free Streamer Delegate

- (void)audioController:(FSAudioController *)audioController preloadStartedForStream:(FSAudioStream *)stream {
    dbug(@"[audioPlayer] audioController:preloadStartedForStream: %@", stream);
}

- (BOOL)audioController:(FSAudioController *)audioController
allowPreloadingForStream:(FSAudioStream *)stream {
    return YES;
}

#pragma mark - Interruption Handling

- (void)registerAudioSession {
    if (!self.registeredAudioSession) {
        [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback
                                             error:nil];
        
        [AVAudioSession.sharedInstance setActive:YES
                                           error:nil];
        
        self.headphoneObserver = [CSNNotificationObserver.alloc initWithName:AVAudioSessionRouteChangeNotification
                                                                      object:nil
                                                                       queue:NSOperationQueue.mainQueue
                                                                  usingBlock:^(NSNotification *notification) {
                                                                      NSNumber *reason = notification.userInfo[AVAudioSessionRouteChangeReasonKey];
                                                                      
                                                                      if(reason.integerValue == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
                                                                          [self pause];
                                                                      }
                                                                  }];
        
        self.registeredAudioSession = YES;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(audioInteruptionOccured:)
                                                   name:AVAudioSessionInterruptionNotification
                                                 object:nil];
    }
}

- (void)audioInteruptionOccured:(NSNotification *)notification {
    NSDictionary *interruptionDictionary = notification.userInfo;
    AVAudioSessionInterruptionType interruptionType = [interruptionDictionary[AVAudioSessionInterruptionTypeKey] integerValue];
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan: {
            dbug(@"[audioPlayer] interruption began");
            [self pause];
        }
            
            break;
        case AVAudioSessionInterruptionTypeEnded: {
            AVAudioSessionInterruptionOptions options = [interruptionDictionary[AVAudioSessionInterruptionOptionKey] integerValue];
            
            BOOL resume = options == AVAudioSessionInterruptionOptionShouldResume;
            
            dbug(@"[audioPlayer] interruption ended, should resume: %@", resume ? @"YES" : @"NO");
            
            if(resume) {
                [self play];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
