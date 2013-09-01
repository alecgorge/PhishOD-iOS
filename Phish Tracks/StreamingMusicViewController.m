//
//  StreamingMusicViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StreamingMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <LastFm/LastFm.h>
#import "PhishTracksStats.h"

@interface StreamingMusicViewController ()
@property NSTimer *timer;
@property BOOL trackHasBeenScrobbled;
@property BOOL updateProgress;
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

- (id)initWithPlaylist:(NSArray *)playlist atIndex:(NSInteger)index {
	if(self = [super initWithNibName:NSStringFromClass([StreamingMusicViewController class])
							  bundle:[NSBundle mainBundle]]) {
		self.playlist = playlist;
		self.isPlaying  = NO;
		self.updateProgress = YES;
		
		self.playerStatus.text = @"";
		self.playerTimeElapsed.text = @"";
		self.playerTimeRemaining.text = @"";
		
		self.currentIndex = index;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.playerAirPlayButton.showsVolumeSlider = NO;
	self.playerAirPlayButton.showsRouteButton = YES;
	self.player = [[MPMoviePlayerController alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(songDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(songPlaybackDidChangeState:)
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(remoteControlReceivedWithEvent:)
												 name:@"RemoteControlEventReceived"
											   object:nil];
	
	self.player.controlStyle = MPMovieControlStyleNone;
	self.player.movieSourceType = MPMovieSourceTypeStreaming;
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
	[audioSession setActive:YES error:nil];
	
	self.isPlaying  = NO;
	
	self.playerStatus.text = @"";
	self.playerTimeElapsed.text = @"";
	self.playerTimeRemaining.text = @"";
	
	[self customizeAirPlayButton];
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[UIButton class]] && [[change valueForKey:NSKeyValueChangeNewKey] intValue] == 1) {
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
	[self setPlayerTitle:nil];
	[self setPlayerSubtitle:nil];
	[self setPlayerPlayPauseButton:nil];
	[self setPlayerNextButton:nil];
	[self setPlayerPreviousButton:nil];
	[self setPlayerTimeRemaining:nil];
	[self setPlayerTimeElapsed:nil];
	[self setPlayerScrubber:nil];
	[self setPlayerStatus:nil];
	
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
		MPMoviePlaybackState state = self.player.playbackState;
		
		if(state == MPMoviePlaybackStatePaused || state == MPMoviePlaybackStateStopped) {
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
	self.player.currentPlaybackTime = ((UISlider*)sender).value * self.currentItem.duration;
}

- (void)songDidFinish:(id)sender {
	if([[sender userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackEnded) {
		[self next];
	}
}

- (void)songPlaybackDidChangeState:(id)sender {
	self.playerStatus.text = @"";

	MPMoviePlaybackState state = self.player.playbackState;
	
	if(state == MPMoviePlaybackStateInterrupted) {
		self.playerStatus.text = @"Buffering...";
		self.isPlaying = YES;
		[self startTimer];
		dbug(@"buffering");
	}
	else if(state == MPMoviePlaybackStatePlaying ) {
		self.isPlaying = YES;
		[self startTimer];
		dbug(@"playing");
	}
	else if(state == MPMoviePlaybackStatePaused) {
		self.isPlaying = NO;
		[self startTimer];
		dbug(@"paused");
	}
	else if(state == MPMoviePlaybackStateStopped) {
		self.isPlaying = NO;
		[self stopTimer];
		dbug(@"stopped");
	}
	
	[self fixPlayPauseButtonImage];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
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
	
	[self.player stop];
	
	StreamingPlaylistItem *item = self.playlist[integer];
	[Flurry logEvent:@"playedTrack"
	  withParameters:@{
					   @"song_name": item.title,
					   @"concert": item.subtitle,
					   @"file": item.file
					   }];
	
	[[LastFm sharedInstance] sendNowPlayingTrack:item.title
										byArtist:@"Phish"
										 onAlbum:item.subtitle
									withDuration:item.duration
								  successHandler:nil
								  failureHandler:nil];
	
	self.trackHasBeenScrobbled = NO;
	
	self.player.contentURL = item.file;
	
	self.playerTitle.text = item.title;
	self.playerSubtitle.text = item.subtitle;
	self.playerTimeElapsed.text = @"00:00";
	self.playerScrubber.value = 0;
	self.playerTimeRemaining.text =  [@"-" stringByAppendingString: [self formatTime: item.duration]];
	
	[self.player play];
	
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
	[self.player play];
	
	[self fixPlayPauseButtonImage];
}

- (void)pause {
	self.isPlaying = NO;
	[self.player pause];
	
	[self fixPlayPauseButtonImage];
}

- (void)playPauseToggle {
	if(self.isPlaying) {
		[self.player pause];
	}
	else {
		[self.player play];
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
		MPMediaItemPropertyAlbumTitle: self.currentItem.subtitle,
		MPMediaItemPropertyTitle: self.currentItem.title,
		MPMediaItemPropertyAlbumTrackCount: [NSNumber numberWithInt: self.playlist.count],
		MPMediaItemPropertyArtist: @"Phish",
		MPMediaItemPropertyAssetURL: self.currentItem.file,
		MPMediaItemPropertyPlaybackDuration: [NSNumber numberWithDouble: self.currentItem.duration]
	}];
	
	NSTimeInterval playbackTime = 0;
	if(self.player.currentPlaybackTime == 0) {
		self.playerStatus.text = @"Buffering...";
	}
	else {
		playbackTime = self.player.currentPlaybackTime;
		self.playerStatus.text = @"";
	}
	
	self.playerTimeElapsed.text = [self formatTime: playbackTime];
	self.playerTimeRemaining.text = [@"-" stringByAppendingString: [self formatTime: self.currentItem.duration - self.player.currentPlaybackTime]];
	
	float complete = playbackTime / self.currentItem.duration;
	
	if(self.updateProgress) {
		self.playerScrubber.value = complete;
	}
	
	if(!self.trackHasBeenScrobbled && complete > .5) {
		[[LastFm sharedInstance] sendScrobbledTrack:self.currentItem.title
										   byArtist:@"Phish"
											onAlbum:self.currentItem.subtitle
									   withDuration:self.currentItem.duration
										atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
									 successHandler:nil
									 failureHandler:nil];
		
		[[PhishTracksStats sharedInstance] playedTrack:self.currentItem.song
											  fromShow:self.currentItem.show
											   success:nil
											   failure:nil];
		self.trackHasBeenScrobbled = YES;
	}
	
	[self fixPlayPauseButtonImage];
}

- (IBAction)share:(id)sender {
	if(NSClassFromString(@"UIActivityViewController")) {
		NSString *textToShare = self.currentItem.shareTitle;
		NSURL *urlToShare = self.currentItem.shareURL;
		NSArray *itemsToShare = @[textToShare, urlToShare];
		
		UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
																				 applicationActivities:nil];
		
		activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects: UIActivityTypePostToWeibo, nil];
		
		AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
		[delegate.tabBar presentViewController:activityVC
									  animated:YES
									completion:nil];
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

-(void)stopTimer {
    [self.timer invalidate];
}

- (void)changePlaylist:(NSArray *)array
	 andStartFromIndex:(NSInteger)index {
	[self stopTimer];
	[self.player stop];
	self.playlist = array;
	self.currentIndex = index;
}

- (IBAction)postionBeginAdjustment:(id)sender {
	self.updateProgress = NO;
}

- (IBAction)positionEndAdjustment:(id)sender {
	self.updateProgress = YES;
}

@end
