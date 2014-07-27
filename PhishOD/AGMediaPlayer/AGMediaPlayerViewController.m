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

#import <LastFm/LastFm.h>
#import <MarqueeLabel/MarqueeLabel.h>

#import "IGDurationHelper.h" 
#import "NowPlayingBarViewController.h"

#import "PHODTrackCell.h"

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
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        self.audioPlayer = STKAudioPlayer.alloc.init;
        self.audioPlayer.delegate = self;        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.uiPlaybackQueueTable registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                                          bundle:nil]
                    forCellReuseIdentifier:@"track"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(remoteControlReceivedWithEvent:)
												 name:@"RemoteControlEventReceived"
											   object:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
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
    for (UISlider *slider in self.uiVolumeView.subviews) {
        if ([slider isKindOfClass:[UISlider class]]) {
            slider.tintColor = COLOR_PHISH_WHITE;
        }
    }
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
    }
    label.text = [NSString stringWithFormat:@"%@ — %@", self.currentItem.displayText, self.currentItem.displaySubText];
    
    self.navigationController.navigationBar.barTintColor = COLOR_PHISH_GREEN;
	
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"glyphicons_halflings_113_chevron-down"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                          target:self
                                                                                          action:@selector(share)];
}

- (void)share {
    self.shareTime = self.audioPlayer.progress;
    
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
    return self.audioPlayer.duration;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 2) return;
    
	if(buttonIndex == 1) {
		self.shareTime = 0;
	}
    
	[Flurry logEvent:@"share"
	  withParameters:@{@"with_time": @(self.shareTime != 0)}];
    
	NSString *textToShare = self.currentItem.shareText;
	NSURL *urlToShare = [self.currentItem shareURLWithTime:self.shareTime];
	NSArray *itemsToShare = @[textToShare, urlToShare];
    
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
																			 applicationActivities:nil];
    
	activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects: UIActivityTypePostToWeibo, nil];
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        [Flurry logEvent:@"share_complete"
          withParameters:@{@"with_time": @(self.shareTime != 0),
                           @"activity_type": activityType,
                           @"completed": @(completed)}];
    };
    
	[self.navigationController presentViewController:activityVC
											animated:YES
										  completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;

    if(!self.doneAppearance) {
        [self setupAppearance];
        
        self.doneAppearance = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
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

- (STKAudioPlayerState)state {
    return self.audioPlayer.state;
}

- (BOOL)playing {
    return self.state == STKAudioPlayerStatePlaying;
}

- (BOOL)buffering {
    return self.state == STKAudioPlayerStateBuffering;
}

- (AGMediaItem *)currentItem {
    if (self.currentIndex >= self.playbackQueue.count) {
        return nil;
    }
    
    return self.playbackQueue[self.currentIndex];
}

- (NSUInteger) nextIndex {
    if(self.loop || self.playbackQueue.count == 1) {
        return self.currentIndex;
    }
    else if(self.shuffle) {
        NSInteger randomIndex = -1;
        while(randomIndex == -1 || randomIndex == self.currentIndex)
            randomIndex = arc4random_uniform((u_int32_t)self.playbackQueue.count);
        return randomIndex;
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

- (void)queueNextItem {
    if (self.nextItem) {
        AGMediaItem *n = self.nextItem;
        [n streamURL:^(NSURL *file) {
            [self.audioPlayer queueURL:file
                       withQueueItemId:n];
        }];
    }

}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;
    
    [self.currentItem streamURL:^(NSURL *file) {
        [self.audioPlayer playURL:file
                  withQueueItemID:self.currentItem];
        
        [self queueNextItem];
    }];
    
    self.currentTrackHasBeenScrobbled = NO;
    
    [[LastFm sharedInstance] sendNowPlayingTrack:self.currentItem.title
                                       byArtist:self.currentItem.artist
                                        onAlbum:self.currentItem.album
                                   withDuration:self.audioPlayer.duration
                                 successHandler:nil
                                 failureHandler:nil];
    
    [self.uiPlaybackQueueTable reloadData];
    [self redrawUI];
}

- (float)progress {
    if(self.audioPlayer.duration == 0.0) {
        return 0;
    }
    
    return self.audioPlayer.progress / self.audioPlayer.duration;
}

- (void)setProgress:(float)progress {
    [self.audioPlayer seekToTime: progress * self.audioPlayer.duration];
    self.uiProgressSlider.value = progress;
}

- (void)forward {
    self.currentIndex = self.nextIndex;
}

- (void)backward {
    if(self.audioPlayer.progress < 10) {
        self.currentIndex--;
    }
    else {
        self.progress = 0.0;
    }
}

- (void)play {
    [self.audioPlayer resume];
    [self redrawUI];
}

- (void)pause {
    [self.audioPlayer pause];
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

- (void)replaceQueueWithItems:(NSArray *)queue startIndex:(NSUInteger)index {
    self.playbackQueue = [queue mutableCopy];
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

#pragma mark - UI Stuff

- (NSString *)stringForStatus:(STKAudioPlayerState)status {
    switch (status) {
        case STKAudioPlayerStateReady:
            return @"Ready";
        case STKAudioPlayerStateRunning:
            return @"Running";
        case STKAudioPlayerStatePlaying:
            return @"Playing";
        case STKAudioPlayerStateBuffering:
            return @"Buffering";
        case STKAudioPlayerStatePaused:
            return @"Paused";
        case STKAudioPlayerStateStopped:
            return @"Stopped";
        case STKAudioPlayerStateError:
            return @"Error";
        case STKAudioPlayerStateDisposed:
            return @"Disposed";
    }
}

- (NSString *)stringForStopReason:(STKAudioPlayerStopReason)status {
    switch (status) {
        case STKAudioPlayerStopReasonNone:
            return @"None";
        case STKAudioPlayerStopReasonEof:
            return @"EOF";
        case STKAudioPlayerStopReasonUserAction:
            return @"User Action";
        case STKAudioPlayerStopReasonPendingNext:
            return @"Pending Next";
        case STKAudioPlayerStopReasonDisposed:
            return @"Disposed";
        case STKAudioPlayerStopReasonError:
            return @"Error";
    }
}

- (NSString *)stringForErrorCode:(STKAudioPlayerErrorCode)status {
    switch (status) {
        case STKAudioPlayerErrorNone:
            return @"None";
        case STKAudioPlayerErrorDataSource:
            return @"Data Source";
        case STKAudioPlayerErrorStreamParseBytesFailed:
            return @"Stream Parse Bytes Failed";
        case STKAudioPlayerErrorAudioSystemError:
            return @"Audio System Error";
        case STKAudioPlayerErrorCodecError:
            return @"Codec Error";
        case STKAudioPlayerErrorDataNotFound:
            return @"Data Not Found";
        case STKAudioPlayerErrorOther:
            return @"Other";
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

// no expensive calculations, just make UI is synced
- (void)redrawUI {
    self.uiPauseButton.hidden = !(self.playing || self.buffering);
    self.uiPlayButton.hidden = self.playing || self.buffering;
    
    self.uiBackwardButton.enabled = self.currentIndex != 0;
    self.uiForwardButton.enabled = self.currentIndex < self.playbackQueue.count;
    
    self.uiTimeElapsedLabel.text = [IGDurationHelper formattedTimeWithInterval:self.audioPlayer.progress];
    self.uiTimeLeftLabel.text = [IGDurationHelper formattedTimeWithInterval:self.audioPlayer.duration];
    
    self.uiProgressSlider.value = self.progress;
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{
        MPMediaItemPropertyAlbumTitle				: self.currentItem.album,
        MPMediaItemPropertyTitle					: self.currentItem.title,
        MPMediaItemPropertyAlbumTrackCount			: @(self.playbackQueue.count),
        MPMediaItemPropertyArtist					: self.currentItem.artist,
        MPMediaItemPropertyPlaybackDuration			: @(self.audioPlayer.duration),
        MPNowPlayingInfoPropertyPlaybackQueueCount	: @(self.playbackQueue.count),
        MPNowPlayingInfoPropertyPlaybackQueueIndex	: @(self.currentIndex),
        MPNowPlayingInfoPropertyPlaybackRate		: @(self.playing ? 1.0 : 0),
        MPNowPlayingInfoPropertyElapsedPlaybackTime	: @(self.audioPlayer.progress)
    }];
    
	if(!self.currentTrackHasBeenScrobbled && self.progress > .5) {
		[[LastFm sharedInstance] sendScrobbledTrack:self.currentItem.title
										   byArtist:self.currentItem.artist
											onAlbum:self.currentItem.album
									   withDuration:self.audioPlayer.duration
										atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
									 successHandler:nil
									 failureHandler:nil];
        
		self.currentTrackHasBeenScrobbled = YES;
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

#pragma mark - ORGMEngineDelegate

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    dbug(@"[audioPlayer] didStartPlayingQueueItemId: %@", queueItemId);
    
    NSUInteger index = [self.playbackQueue indexOfObject:queueItemId];
    _currentIndex = index;
    
    [self queueNextItem];
    
    self.currentTrackHasBeenScrobbled = NO;
    
    [self.uiPlaybackQueueTable reloadData];
    [self setupBar];
}

/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    dbug(@"[audioPlayer] didFinishBufferingSourceWithQueueItemId: %@", queueItemId);
    
    [self.uiPlaybackQueueTable reloadData];
}

/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    dbug(@"[audioPlayer] stateChanged: %@ previousState: %@", [self stringForStatus:state], [self stringForStatus:previousState]);
    [self updateStatusBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AGMediaItemStateChanged"
                                                        object:self];
    
    [self.uiPlaybackQueueTable reloadData];
    
    [self setupBar];
}

/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
didFinishPlayingQueueItemId:(NSObject*)queueItemId
         withReason:(STKAudioPlayerStopReason)stopReason
        andProgress:(double)progress
        andDuration:(double)duration {
    dbug(@"[audioPlayer] didFinishPlayingQueueItemId: %@ withReason: %@ andProgress: %f andDuration: %f", queueItemId, [self stringForStopReason:stopReason], progress, duration);
}

/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
    unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    dbug(@"[audioPlayer] unexpectedError: %@", [self stringForErrorCode:errorCode]);
}

/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
            logInfo:(NSString*)line {
    dbug(@"[audioPlayer] logInfo: %@", line);
}

/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer
didCancelQueuedItems:(NSArray*)queuedItems {
    dbug(@"[audioPlayer] didCancelQueuedItems: %@", queuedItems);
}

@end