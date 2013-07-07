//
//  AppDelegate.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AppDelegate.h"
#import "YearsViewController.h"
#import "StreamingMusicViewController.h"
#import <LastFm.h>
#import "SettingsViewController.h"
#import "TopRatedViewController.h"
#import "SongsViewController.h"
#import <FlurrySDK/Flurry.h>
#import <Crashlytics/Crashlytics.h>
#import <TestFlight.h>

@implementation AppDelegate

@synthesize tabBar;
@synthesize window;
@synthesize yearsNav;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Flurry startSession:@"JJNX7YHMWM34SFD2GG8K"];
	[TestFlight takeOff:@"b7d72e8f-eafb-43c2-ac00-238f786848c2"];
	[Crashlytics startWithAPIKey:@"bbdd6a4df81e6b1498130a0f1fbf72d14e334fb4"];
	[self setupLastFM];
	[self setupCaching];
	
    self.window = [[EventInterceptWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.eventInterceptDelegate = self;
	
	self.shouldShowNowPlaying = NO;
    
	self.tabBar = [[UITabBarController alloc] init];
	[self setupNowPlaying];
	
	YearsViewController *years = [[YearsViewController alloc] init];
	self.yearsNav = [[UINavigationController alloc] initWithRootViewController:years];
	self.yearsNav.delegate = self;
	self.yearsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"By Year"
															 image:[UIImage imageNamed:@"83-calendar.png"]
															   tag:0];
	
	SettingsViewController *set = [[SettingsViewController alloc] init];
	UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:set];
	settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
														   image:[UIImage imageNamed:@"19-gear.png"]
															 tag:2];
	
	SongsViewController *songs = [[SongsViewController alloc] init];
	UINavigationController *songsNav = [[UINavigationController alloc] initWithRootViewController:songs];
	songsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"By Song"
														image:[UIImage imageNamed:@"44-shoebox.png"]
														  tag:1];
	songsNav.delegate = self;
	
	TopRatedViewController *top = [[TopRatedViewController alloc] init];
	UINavigationController *topNav = [[UINavigationController alloc] initWithRootViewController:top];
	topNav.tabBarItem   = [[UITabBarItem alloc] initWithTitle:@"Top Rated"
														image:[UIImage imageNamed:@"28-star.png"]
														  tag:1];
	topNav.delegate = self;
	
	self.tabBar.viewControllers = @[self.yearsNav, songsNav, topNav, settingsNav];
	
	self.window.rootViewController = self.tabBar;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)interceptEvent:(UIEvent *)event {
	if(!self.isNowPlayingVisible) {
		return NO;
	}
	
    NSSet *touches = [event allTouches];
    UITouch *oneTouch = [touches anyObject];
    UIView *touchView = [oneTouch view];
    //  NSLog(@"tap count = %d", [oneTouch tapCount]);
    // check for taps on the web view which really end up being dispatched to
    // a scroll view
    if (touchView && [touchView isDescendantOfView:self.tabBar.selectedViewController.view]
		&& touches && oneTouch.phase == UITouchPhaseBegan) {
        [self toggleNowPlaying];
		return YES;
    }
    return NO;
}

- (void)setShouldShowNowPlaying:(BOOL)s {
	_shouldShowNowPlaying = s;
	if(!s) return;
	[self navigationController:self.yearsNav
		willShowViewController:self.yearsNav.visibleViewController
					  animated:YES];
}

- (void)setupCaching {
	[[NSURLCache sharedURLCache] setMemoryCapacity:1024 * 1024 * 10];
	[[NSURLCache sharedURLCache] setDiskCapacity:1024 * 1024 * 256];
}

- (void)setupLastFM {
    [LastFm sharedInstance].apiKey = @"f2b89dbc431a938a385203bb218e5310";
    [LastFm sharedInstance].apiSecret = @"5c1ace2f9e7cdbb4c0b2fbbcc9ddb426";
    [LastFm sharedInstance].session = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastfm_session_key"];
    [LastFm sharedInstance].username = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastfm_username_key"];
}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated {
	if(!self.shouldShowNowPlaying) return;
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Player"
															   style:UIBarButtonItemStyleDone
															  target:self
															  action:@selector(nowPlaying)];
	
    viewController.navigationItem.rightBarButtonItem = button;
}

- (void)setupNowPlaying {
	StreamingMusicViewController *nowPlaying = [StreamingMusicViewController sharedInstance];
	
	CGRect f = nowPlaying.view.frame;
	f.origin.y = self.tabBar.selectedViewController.view.frame.size.height - 216.0f - self.tabBar.tabBar.frame.size.height;
	f.size.width = self.tabBar.view.frame.size.width;
	nowPlaying.view.frame = f;
	
	self.isNowPlayingVisible = NO;
	
	[self.tabBar.view addSubview: nowPlaying.view];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived"
														object:event];
}

- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration {
	[self toggleNowPlaying];
}

- (void)application:(UIApplication *)application
didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
	
}

- (void)nowPlaying {
	StreamingMusicViewController *nowPlaying = [StreamingMusicViewController sharedInstance];
	
	[UIView animateWithDuration:0.2
					 animations:^{
						 CGRect v = self.tabBar.selectedViewController.view.frame;
						 CGRect f = nowPlaying.view.frame;
						 f.size.width = v.size.width;
						 f.size.height = 216.0f;
						 
						 if(self.isNowPlayingVisible) {
							 f.origin.y = v.size.height + self.tabBar.tabBar.frame.size.height;
							 [nowPlaying viewWillDisappear: YES];
						 }
						 else {
							 f.origin.y = v.size.height - f.size.height;
							 [nowPlaying viewWillAppear: YES];
						 }
						 
						 self.isNowPlayingVisible = !self.isNowPlayingVisible;

						 nowPlaying.view.frame = f;
					 }
					 completion:^(BOOL finished) {
						 if(!self.isNowPlayingVisible) {
							 [nowPlaying viewDidDisappear: YES];
						 }
						 else {
							 [nowPlaying viewDidAppear: YES];
						 }
					 }];
}

- (void)toggleNowPlaying {
	[self nowPlaying];
}

- (void)showNowPlaying {
	self.isNowPlayingVisible = NO;
	[self nowPlaying];
}

@end
