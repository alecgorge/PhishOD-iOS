//
//  NowPlayingViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "PhishTrackProvider.h"
#import "AppDelegate.h"

@implementation NowPlayingViewController

-(id)init {
	if (self = [super initWithNibName:@"BeamMusicPlayerViewController"
							   bundle:[NSBundle mainBundle]]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(remoteControlEventNotification:)
													 name:@"RemoteControlEventReceived"
												   object:nil];
		
		NowPlayingViewController *p = self;
		self.backBlock = ^{
			[p dismiss:nil];
		};
		self.actionBlock = ^{
			[p share:nil];
		};
		
		self.delegate = [PhishTrackProvider sharedInstance];
		self.dataSource = [PhishTrackProvider sharedInstance];
		
		self.shouldHideNextTrackButtonAtBoundary = YES;
		self.shouldHidePreviousTrackButtonAtBoundary = YES;
		self.navigationController.navigationBar.hidden = YES;
	}
	return self;
}

-(void)remoteControlEventNotification:(NSNotification *)note{
    UIEvent *event = note.object;
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.playing){
                    [self pause];
                } else {
                    [self play];
                }
                break;
			case UIEventSubtypeRemoteControlNextTrack:
				[self next];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[self previous];
				break;
			case UIEventSubtypeRemoteControlStop:
				[self stop];
				break;
            default:
                break;
        }
    }
}

-(void)currentTrackFinished {
    if ( self.repeatMode != MPMusicRepeatModeOne ){
        [self next];
		
    } else {
		[super currentPlaybackPosition];
    }
}

-(void)viewWillAppear:(BOOL)animated {
//	self.navigationItem.rightBarButtonItem = nil;
//	self.navigationController.navigationBar.hidden = YES;
//	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	((AppDelegate*)[UIApplication sharedApplication].delegate).shouldShowNowPlaying = YES;
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			target:self
																			action:@selector(dismiss:)];
	self.navigationItem.rightBarButtonItem = button;
	UIBarButtonItem *buttoa = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			target:self
																			action:@selector(share:)];
	self.navigationItem.leftBarButtonItem = buttoa;
//	self.navigationController.navigationBar.hidden = NO;
}

- (void)dismiss:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)share:(id)sender {
	PhishTrackProvider *provider = (PhishTrackProvider*)self.dataSource;
	
	NSString *song = provider.currentSong.title;
	NSString *url = [NSString stringWithFormat:@"http://www.phishtracks.com/shows/%@/%@", provider.show.showDate, provider.currentSong.slug];
	
	NSString *textToShare = [NSString stringWithFormat:@"I am listening to %@ from %@.", song, provider.show.showDate];
    NSArray *itemsToShare = @[textToShare, [NSURL URLWithString:url]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
																			 applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    [self presentViewController:activityVC
					   animated:YES
					 completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
//	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

+(NowPlayingViewController*)sharedInstance {
	static dispatch_once_t once;
    static NowPlayingViewController *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [self new];
	});
    return sharedFoo;
}

@end
