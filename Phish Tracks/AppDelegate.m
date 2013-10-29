//
//  AppDelegate.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AppDelegate.h"
#import "Configuration.h"
#import "RotatableTabBarController.h"

#import "StreamingMusicViewController.h"

#import "YearsViewController.h"
#import "SongsViewController.h"
#import "TopRatedViewController.h"
#import "PhishTracksStatsViewController.h"
#import "SettingsViewController.h"

#import <LastFm.h>
#import <FlurrySDK/Flurry.h>
#import <Crashlytics/Crashlytics.h>
#import <TestFlight.h>

static AppDelegate *sharedDelegate;

@implementation AppDelegate

@synthesize tabBar;
@synthesize window;
@synthesize yearsNav;

+ (instancetype)sharedDelegate {
	return sharedDelegate;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	sharedDelegate = self;
	
	[Flurry startSession:@"JJNX7YHMWM34SFD2GG8K"];
	[TestFlight takeOff:@"b7d72e8f-eafb-43c2-ac00-238f786848c2"];
	[Crashlytics startWithAPIKey:@"bbdd6a4df81e6b1498130a0f1fbf72d14e334fb4"];

	[self setupLastFM];
	[self setupCaching];
	[self setupAppearance];
	
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	self.shouldShowNowPlaying = NO;
	
	[self setupNowPlaying];
	
	YearsViewController *years = [[YearsViewController alloc] init];
	self.yearsNav = [[UINavigationController alloc] initWithRootViewController:years];
	self.yearsNav.navigationBar.translucent = NO;
	
	self.panels = [[JASidePanelController alloc] init];
	self.menuPanel = [[MenuPanel alloc] init];
	
	self.panels.leftFixedWidth = 256.0;
	
	self.panels.leftPanel = self.menuPanel;
	self.panels.centerPanel = yearsNav;
	
	self.window.rootViewController = self.panels;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupAppearance {
	UIColor *phishGreen = COLOR_PHISH_GREEN;
	UIColor *lightPhishGreen = COLOR_PHISH_LIGHT_GREEN;
	UIColor *white = COLOR_PHISH_WHITE;
	
	[UINavigationBar appearance].barTintColor = phishGreen;
	[UINavigationBar appearance].tintColor = white;
	[UINavigationBar appearance].titleTextAttributes = @{UITextAttributeTextColor: white};
	
	[UISegmentedControl appearance].tintColor = phishGreen;
//	[UITableViewHeaderFooterView appearance].tintColor = lightPhishGreen;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
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

- (void)setupNowPlaying {
	StreamingMusicViewController *nowPlaying = [StreamingMusicViewController sharedInstance];
	self.nowPlayingNav = [[UINavigationController alloc] initWithRootViewController:nowPlaying];
	self.nowPlayingNav.navigationBar.translucent = NO;
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived"
														object:event];
}

- (void)nowPlaying {
	[self.panels presentViewController:self.nowPlayingNav
							  animated:YES
							completion:^{}];
}

- (void)toggleNowPlaying {
	[self nowPlaying];
}

- (void)showNowPlaying {
	self.isNowPlayingVisible = NO;
	[self nowPlaying];
}

- (BOOL)application:(UIApplication *)application
			openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
		 annotation:(id)annotation {
	if([url.scheme isEqualToString:@"phishod"]) {
		NSArray *comps = url.pathComponents;
		
		if(comps.count == 0) {
			// phishod:///
			// nothing, just opening app
		}
		else if(comps.count == 1) {
			// phishod:///:show_id
			// open to date
		}
		else if(comps.count == 2) {
			// phishod:///:show_id/:track_id
			// open to track
		}
		else if(comps.count == 3 || comps.count == 4) {
			// phishod:///:show_id/:track_id/3[/20]
			// open to 3[:20] on light
			NSTimeInterval position = [comps[2] integerValue];
			
			if(comps.count == 4)  {
				position += [comps[3] floatValue] / 60.0;
			}
			
			NSString *show_id = comps[0];
			NSString *track_id = comps[1];
		}
	}
	
	return NO;
}

@end
