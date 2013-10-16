//
//  StreamingMusicViewController.m
//  Listen to the Dead
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StreamingMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <LastFm/LastFm.h>

#import "AppDelegate.h"

@interface StreamingMusicViewController () {
	const NSString *ItemStatusContext;
	const char IndexKey;
}

@property NSTimeInterval shareTime;

@property NSTimer *timer;
@property BOOL trackHasBeenScrobbled;
@property BOOL updateProgress;
@property (nonatomic) NSInteger previousIndex;

@property (nonatomic) NSMutableArray *notifiers;

@end

@implementation StreamingMusicViewController

+ (StreamingMusicViewController*) sharedInstance {
	static dispatch_once_t once;
    static StreamingMusicViewController *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] initWithPlaylist:@[] atIndex:0];
	});
    return sharedFoo;
}

// table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.playlist ? self.playlist.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:@"Cell"];
	}
	
	StreamingPlaylistItem *item = self.playlist[indexPath.row];
	
	cell.textLabel.text = item.title;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	cell.detailTextLabel.text = [self formatTime: item.duration];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.row == self.currentIndex) {
		cell.imageView.image = [UIImage imageNamed:@"glyphicons_173_play.png"];
	}
	else {
		cell.imageView.image = nil;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	self.currentIndex = indexPath.row;
	
	[tableView reloadData];
}
// end table view

- (id)initWithPlaylist:(NSArray *)playlist atIndex:(NSInteger)index {
	if(self = [super initWithNibName:NSStringFromClass([StreamingMusicViewController class])
							  bundle:[NSBundle mainBundle]]) {
		self.playlist = playlist;
		self.isPlaying  = NO;
		self.updateProgress = YES;
		
		self.title = @"";
		self.playerTimeElapsed.text = @"";
		self.playerTimeRemaining.text = @"";
		self.notifiers = [NSMutableArray array];
		
		self.currentIndex = index;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.playerAirPlayButton.showsVolumeSlider = NO;
	self.playerAirPlayButton.showsRouteButton = YES;
	
	self.audioPlayer = [[AudioPlayer alloc] init];
	self.audioPlayer.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(remoteControlReceivedWithEvent:)
												 name:@"RemoteControlEventReceived"
											   object:nil];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
	[audioSession setActive:YES error:nil];
	
	self.isPlaying  = NO;
	
	self.title = @"";
	self.playerTimeElapsed.text = @"";
	self.playerTimeRemaining.text = @"";
	
	[self customizeAirPlayButton];
	
	[self setupNavButtons];
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)setupNavButtons {
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(dismiss)];
	
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share"
																	style:UIBarButtonItemStyleBordered
																   target:self
																   action:@selector(share:)];
	
	self.navigationItem.rightBarButtonItem = hideButton;
	self.navigationItem.leftBarButtonItem = shareButton;
}

- (void)dismiss {
	[self.navigationController dismissViewControllerAnimated:YES
												  completion:NULL];
}

- (void)customizeAirPlayButton {
	MPVolumeView *volumeView = self.playerAirPlayButton;
	[volumeView setShowsVolumeSlider:NO];
	for (UIButton *button in volumeView.subviews) {
		if ([button isKindOfClass:[UIButton class]]) {
			self.mpAirPlayButton = button;
						
			[self.mpAirPlayButton addObserver:self
								   forKeyPath:@"alpha"
									  options:NSKeyValueObservingOptionNew
									  context:nil];
			
			[self fixAirPlayButtonColor];
		}
	}
	[volumeView sizeToFit];	
}

- (void)fixAirPlayButtonColor {
	UIImage *img = [self.mpAirPlayButton imageForState: UIControlStateNormal];
	
	[self.mpAirPlayButton setImage:[self ipMaskedImage:img
												 color:[UIColor blackColor]]
						  forState:UIControlStateNormal];
	
	img = [self.mpAirPlayButton imageForState: UIControlStateHighlighted];
	[self.mpAirPlayButton setImage:[self ipMaskedImage:img
												 color:[UIColor blackColor]]
						  forState:UIControlStateHighlighted];
	
	img = [self.mpAirPlayButton imageForState: UIControlStateSelected];
	[self.mpAirPlayButton setImage:[self ipMaskedImage:img
												 color:[UIColor blackColor]]
						  forState:UIControlStateSelected];
}

- (UIImage *)ipMaskedImage:(UIImage *)image
					 color:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state {
	[self fixPlayPauseButtonImage];

	if(state == AudioPlayerStateReady) {
		NSLog(@"state: AudioPlayerStateReady");
	}
	else if(state == AudioPlayerStateRunning) {
		NSLog(@"state: AudioPlayerStateRunning");
	}
	else if(state == AudioPlayerStatePlaying) {
		NSLog(@"state: AudioPlayerStatePlaying");
	}
	else if(state == AudioPlayerStatePaused) {
		NSLog(@"state: AudioPlayerStatePaused");
	}
	else if(state == AudioPlayerStateStopped) {
		NSLog(@"state: AudioPlayerStateStopped");
	}
	else if(state == AudioPlayerStateError) {
		NSLog(@"state: AudioPlayerStateError");
	}
	else if(state == AudioPlayerStateDisposed) {
		NSLog(@"state: AudioPlayerStateDisposed");
	}
	else {
		NSLog(@"state: %d", state);
	}
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode {
	if(errorCode == AudioPlayerErrorNone) {
		NSLog(@"error: AudioPlayerErrorNone");
	}
	else if(errorCode == AudioPlayerErrorDataSource) {
		NSLog(@"error: AudioPlayerErrorDataSource");
	}
	else if(errorCode == AudioPlayerErrorStreamParseBytesFailed) {
		NSLog(@"error: AudioPlayerErrorStreamParseBytesFailed");
	}
	else if(errorCode == AudioPlayerErrorDataNotFound) {
		NSLog(@"error: AudioPlayerErrorDataNotFound");
	}
	else if(errorCode == AudioPlayerErrorQueueStartFailed) {
		NSLog(@"error: AudioPlayerErrorQueueStartFailed");
	}
	else if(errorCode == AudioPlayerErrorQueuePauseFailed) {
		NSLog(@"error: AudioPlayerErrorQueuePauseFailed");
	}
	else if(errorCode == AudioPlayerErrorUnknownBuffer) {
		NSLog(@"error: AudioPlayerErrorUnknownBuffer");
	}
	else if(errorCode == AudioPlayerErrorQueueStopFailed) {
		NSLog(@"error: AudioPlayerErrorQueueStopFailed");
	}
	else if(errorCode == AudioPlayerErrorOther) {
		NSLog(@"error: AudioPlayerErrorOther");
	}
	else {
		NSLog(@"error: %d", errorCode);
	}
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
	NSLog(@"started playing: %@", queueItemId);
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
	NSLog(@"finished buffering: %@", queueItemId);
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
	NSLog(@"finished %@. progress: %lf duration: %lf", queueItemId, progress, duration);
	
	if(stopReason == AudioPlayerStopReasonEof) {
		NSLog(@"reason: AudioPlayerStopReasonEof");
	}
	else if(stopReason == AudioPlayerStopReasonNoStop) {
		NSLog(@"reason: AudioPlayerStopReasonNoStop");
	}
	else if(stopReason == AudioPlayerStopReasonUserAction) {
		NSLog(@"reason: AudioPlayerStopReasonUserAction");
	}
	else if(stopReason == AudioPlayerStopReasonUserActionFlushStop) {
		NSLog(@"reason: AudioPlayerStopReasonUserActionFlushStop");
	}
	else {
		NSLog(@"reason: %d", stopReason);
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    if([object isKindOfClass:[UIButton class]]
	&& [[change valueForKey:NSKeyValueChangeNewKey] intValue] == 1) {
		[self fixAirPlayButtonColor];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.layer.masksToBounds = NO;
	self.view.layer.shadowOffset = CGSizeMake(0, -5);
	self.view.layer.shadowRadius = 5;
	self.view.layer.shadowOpacity = 0.7;
	self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect: self.view.bounds].CGPath;
}

- (void)viewDidUnload {
	[self setPlayerSubtitle:nil];
	[self setPlayerPlayPauseButton:nil];
	[self setPlayerNextButton:nil];
	[self setPlayerPreviousButton:nil];
	[self setPlayerTimeRemaining:nil];
	[self setPlayerTimeElapsed:nil];
	[self setPlayerScrubber:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self.mpAirPlayButton removeObserver:self forKeyPath:@"alpha"];
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];

	
	[self setView:nil];
	[self setPlayerPauseButton:nil];
	[self setPlayerAirPlayButton:nil];
	[super viewDidUnload];
}

- (void)remoteControlReceivedWithEvent:(NSNotification *)note {
    UIEvent *event = note.object;
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self play];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self playPauseToggle];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
			[self next];
		} else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
			[self previous];
		}
    }
}

- (void)fixPlayPauseButtonImage {
	dispatch_async(dispatch_get_main_queue(), ^{
		if(self.audioPlayer.state != AudioPlayerStatePlaying) {
			self.playerPauseButton.hidden = YES;
		}
		else {
			self.playerPauseButton.hidden = NO;
		}
		
		if(self.currentIndex == 0) {
			self.playerPreviousButton.enabled = NO;
			self.playerPreviousButton.alpha = 0.5;
		}
		else {
			self.playerPreviousButton.enabled = YES;
			self.playerPreviousButton.alpha = 1.0;
		}
		
		if(self.currentIndex == self.playlist.count - 1) {
			self.playerNextButton.enabled = NO;
			self.playerNextButton.alpha = 0.5;
		}
		else {
			self.playerNextButton.enabled = YES;
			self.playerNextButton.alpha = 1.0;
		}		
	});
}

- (IBAction)playerPlayPauseTapped:(id)sender {
	[self playPauseToggle];
}

- (IBAction)playerNextTapped:(id)sender {
	[self next];
}

- (IBAction)playerPreviousTapped:(id)sender {
	[self previous];
}

- (IBAction)playerProgressScrubbed:(id)sender {
	[self.audioPlayer seekToTime:((UISlider*)sender).value * self.currentItem.duration];
}

- (void)songDidFinish:(id)sender {
	if([[sender userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackEnded) {
		[self next];
	}
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
	self.previousIndex = _currentIndex;
	
	[self.playerTableView reloadData];
	[self.playerTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:currentIndex
																	 inSection:0]
								atScrollPosition:UITableViewScrollPositionMiddle
										animated:YES];
	
	_currentIndex = currentIndex;
	[self playIndex: currentIndex];
	[self fixPlayPauseButtonImage];
}

- (StreamingPlaylistItem *)currentItem {
	if(self.currentIndex + 1> self.playlist.count) {
		return nil;
	}
	return self.playlist[self.currentIndex];
}

- (void)playIndex:(NSInteger)integer {
	if(self.playlist.count == 0) {
		return;
	}
	
	StreamingPlaylistItem *item = self.playlist[integer];
	[Flurry logEvent:@"playedTrack"
	  withParameters:@{
					   @"song_name": item.title,
					   @"concert": item.subtitle,
					   @"file": item.file
					   }];
	
	[[LastFm sharedInstance] sendNowPlayingTrack:item.title
										byArtist:item.artist
										 onAlbum:item.subtitle
									withDuration:item.duration
								  successHandler:nil
								  failureHandler:nil];
	
	self.trackHasBeenScrobbled = NO;
	
	if(integer - 1 == self.previousIndex) {
		NSLog(@"Advancing to next item");
		[self.audioPlayer seekToTime:10000000000000.0];
		
		if(integer + 1 < self.playlist.count) {
			DataSource *ds = [self.audioPlayer dataSourceFromURL:[self.playlist[integer + 1] file]];
			ds = [[AutoRecoveringHttpDataSource alloc] initWithDataSource:ds];
			[self.audioPlayer queueDataSource:ds
							  withQueueItemId:[self.playlist[integer + 1] title]];
		}
	}
	else {
		[self.audioPlayer stop];
		DataSource *ds1 = [self.audioPlayer dataSourceFromURL:[self.playlist[integer] file]];
		ds1 = [[AutoRecoveringHttpDataSource alloc] initWithDataSource:ds1];
		[self.audioPlayer queueDataSource:ds1
						  withQueueItemId:[self.playlist[integer] title]];
		
		DataSource *ds = [self.audioPlayer dataSourceFromURL:[self.playlist[integer + 1] file]];
		ds = [[AutoRecoveringHttpDataSource alloc] initWithDataSource:ds];
		[self.audioPlayer queueDataSource:ds
						  withQueueItemId:[self.playlist[integer + 1] title]];
		
		[self.audioPlayer resume];
	}
	
	self.playerTitle.text = item.title;
	self.playerSubtitle.text = item.subtitle;
	self.playerTimeElapsed.text = @"00:00";
	self.playerScrubber.value = 0;
	self.playerTimeRemaining.text =  [@"-" stringByAppendingString: [self formatTime: item.duration]];

	[self startTimer];
}

- (NSString *)formatTime:(NSTimeInterval)dur {
	int totalSeconds = floor(dur);
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
	
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)play {
	self.isPlaying = YES;
	[self.audioPlayer resume];
	
	[self fixPlayPauseButtonImage];
}

- (void)pause {
	self.isPlaying = NO;
	[self.audioPlayer pause];
	
	[self fixPlayPauseButtonImage];
}

- (void)playPauseToggle {
	if(self.isPlaying) {
		[self.audioPlayer pause];
	}
	else {
		[self.audioPlayer resume];
	}
	
	self.isPlaying = !self.isPlaying;
	[self fixPlayPauseButtonImage];
}

- (void)next {
	if(self.currentIndex + 1 < self.playlist.count) {
		self.currentIndex = self.currentIndex + 1;
	}
	[self fixPlayPauseButtonImage];
}

- (void)previous {
	if(self.currentIndex > 0) {
		self.currentIndex = self.currentIndex - 1;
	}
	[self fixPlayPauseButtonImage];
}

-(void)startTimer {
	if(self.timer.isValid) {
		return;
	}
	
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
												  target:self
												selector:@selector(updateInfo)
												userInfo:nil
												 repeats:YES];
}

- (void)updateInfo {
	if(self.currentItem == nil) {
		return;
	}
	
	[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{
		MPMediaItemPropertyAlbumTitle				: self.currentItem.subtitle,
		MPMediaItemPropertyTitle					: self.currentItem.title,
		MPMediaItemPropertyAlbumTrackCount			: [NSNumber numberWithUnsignedInteger: self.playlist.count],
		MPMediaItemPropertyArtist					: self.currentItem.artist,
		MPMediaItemPropertyAssetURL					: self.currentItem.file,
		MPMediaItemPropertyPlaybackDuration			: [NSNumber numberWithDouble: self.currentItem.duration],
		MPNowPlayingInfoPropertyPlaybackQueueCount	: [NSNumber numberWithUnsignedInteger: self.playlist.count],
		MPNowPlayingInfoPropertyPlaybackQueueIndex	: [NSNumber numberWithUnsignedInteger: self.currentIndex],
		MPNowPlayingInfoPropertyPlaybackRate		: [NSNumber numberWithBool:self.isPlaying],
		MPNowPlayingInfoPropertyElapsedPlaybackTime	: [NSNumber numberWithInt: self.audioPlayer.progress]
	}];
	
	NSTimeInterval playbackTime = 0;
	if(self.audioPlayer.progress == 0
	|| (   self.audioPlayer.state != AudioPlayerStateStopped
	    && self.audioPlayer.state != AudioPlayerStatePlaying
		&& self.audioPlayer.state != AudioPlayerStatePaused)) {
		self.title = @"Buffering...";
	}
	else {
		playbackTime = self.audioPlayer.progress;
		self.title = @"";
	}
	
	self.playerTitle.text = self.currentItem.title;
	self.playerSubtitle.text = self.currentItem.subtitle;
	self.playerTimeElapsed.text = [self formatTime: playbackTime];
	self.playerTimeRemaining.text = [@"-" stringByAppendingString: [self formatTime: self.audioPlayer.duration - playbackTime]];
	
	float complete = playbackTime / self.currentItem.duration;
	
	if(self.updateProgress) {
		self.playerScrubber.value = complete;
	}
	
	if(!self.trackHasBeenScrobbled && complete > .5) {
		[[LastFm sharedInstance] sendScrobbledTrack:self.currentItem.title
										   byArtist:self.currentItem.artist
											onAlbum:self.currentItem.subtitle
									   withDuration:self.currentItem.duration
										atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
									 successHandler:nil
									 failureHandler:nil];
		
		self.trackHasBeenScrobbled = YES;
	}
	
	[[AppDelegate sharedDelegate].menuPanel updateNowPlayingWithStreamingPlaylistItem:self.currentItem];
	
	[self fixPlayPauseButtonImage];
	[self.playerTableView reloadData];
}

- (IBAction)share:(id)sender {
	if(NSClassFromString(@"UIActivityViewController")) {
		self.shareTime = self.audioPlayer.progress;
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to include your current position in the song (%@) when you share this song?", [self formatTime:self.shareTime]]
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
	else {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Not available on iOS 5"
													message:@"Sharing songs is a feature not available on anything less than iOS 6"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
		[a show];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 2) return;
	
	if(buttonIndex == 1) {
		self.shareTime = 0;
	}
	
	NSString *textToShare = self.currentItem.shareTitle;
	NSURL *urlToShare = [self.currentItem shareURLWithPlayedTime:self.shareTime];
	NSArray *itemsToShare = @[textToShare, urlToShare];
	
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
																			 applicationActivities:nil];
	
	activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects: UIActivityTypePostToWeibo, nil];
	
	[self.navigationController presentViewController:activityVC
											animated:YES
										  completion:nil];
}

-(void)stopTimer {
    [self.timer invalidate];
}

- (void)changePlaylist:(NSArray *)array
	 andStartFromIndex:(NSInteger)index {
	[self stopTimer];
	[self.audioPlayer stop];
	
	self.playlist = array;
	
	self.previousIndex = -2;
	_currentIndex = -2;
	
	self.currentIndex = index;
}

- (IBAction)postionBeginAdjustment:(id)sender {
	self.updateProgress = NO;
}

- (IBAction)positionEndAdjustment:(id)sender {
	self.updateProgress = YES;
}

@end
