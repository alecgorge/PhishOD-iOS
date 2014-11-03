//
//  AppDelegate.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AppDelegate.h"
#import "RotatableTabBarController.h"

#import "YearsViewController.h"
#import "SongsViewController.h"
#import "TopRatedViewController.h"
#import "PhishTracksStatsViewController.h"
#import "SettingsViewController.h"
#import "HomeViewController.h"
#import "AGMediaPlayerViewController.h"
#import "IGThirdPartyKeys.h"
#import "ShowViewController.h"
#import "IGEvents.h"

#import <LastFm.h>
#import <Crashlytics/Crashlytics.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <EGOCache/EGOCache.h>

#import <PSUpdateApp/PSUpdateApp.h>

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

    if(IGThirdPartyKeys.sharedInstance.isCrashlyticsEnabled) {
        [Crashlytics startWithAPIKey:IGThirdPartyKeys.sharedInstance.crashlyticsApiKey];
    }
	
    [IGEvents setup];
    
	[AFNetworkActivityLogger.sharedLogger startLogging];
	
	// prevent LivePhish.com and Phish.net from logging passwords in plaintext
	AFNetworkActivityLogger.sharedLogger.filterPredicate = [NSPredicate predicateWithBlock:^BOOL(NSURLRequest *op, NSDictionary *bindings) {
		return [op.URL.query containsString:@"session.getUserToken"] || [op.URL.query containsString:@"passwd="];
	}];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *ptsServer = infoDictionary[@"StatsServer"];
	[PhishTracksStats setupWithAPIKey:IGThirdPartyKeys.sharedInstance.phishtracksStatsApiKey andBaseUrl:ptsServer];

	[self setupLastFM];
	[self setupCaching];
	[self setupAppearance];
	
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	self.shouldShowNowPlaying = NO;
	
    self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.alloc.init;
	
	HomeViewController *years = [[HomeViewController alloc] init];
	self.yearsNav = [[UINavigationController alloc] initWithRootViewController:years];
    self.yearsNav.delegate = self.navDelegate;
	self.yearsNav.navigationBar.translucent = NO;

	self.window.rootViewController = self.yearsNav;
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	[self checkForUpdates];
	
	[AFNetworkReachabilityManager.sharedManager startMonitoring];

    [UIApplication.sharedApplication beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
    return YES;
}

- (void)checkForUpdates {
#if defined(ADHOC)
    [PSUpdateApp.manager startWithRoute:@"http://phishapp.alecgorge.com/beta/data.json"];
    [PSUpdateApp.manager setStrategy:ForceStrategy];
    
    PSUpdateApp.manager.alertTitle = @"Update Available";
	PSUpdateApp.manager.alertForceMessage = @"A new PhishOD beta is available. You need to update to continue using the beta.";
	
	[PSUpdateApp.manager detectAppVersion:nil];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self checkForUpdates];
}

- (void)setupAppearance {
	UIColor *phishGreen = COLOR_PHISH_GREEN;
	UIColor *white = COLOR_PHISH_WHITE;
	
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
		
		[UINavigationBar appearance].barTintColor = phishGreen;
		[UINavigationBar appearance].tintColor = white;
		
		[UIToolbar appearance].barTintColor = phishGreen;
		[UIToolbar appearance].tintColor = white;
        
        [UIBarButtonItem appearance].tintColor = white;
		
		[UISegmentedControl appearance].tintColor = phishGreen;
	}
	else {
		[UINavigationBar appearance].tintColor = phishGreen;
	}

	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: white};
	
//	[UITableViewHeaderFooterView appearance].tintColor = lightPhishGreen;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

- (void)setupCaching {
	EGOCache.globalCache.defaultTimeoutInterval = 60 * 60 * 24 * 365 * 10;
}

- (void)setupLastFM {
    if(IGThirdPartyKeys.sharedInstance.isLastFmEnabled) {
        LastFm.sharedInstance.apiKey = IGThirdPartyKeys.sharedInstance.lastFmApiKey;
        LastFm.sharedInstance.apiSecret = IGThirdPartyKeys.sharedInstance.lastFmApiSecret;
        LastFm.sharedInstance.session = [NSUserDefaults.standardUserDefaults stringForKey:@"lastfm_session_key"];
        LastFm.sharedInstance.username = [NSUserDefaults.standardUserDefaults stringForKey:@"lastfm_username_key"];
    }
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived"
														object:event];
}

- (void)nowPlaying {
	[self.window.rootViewController presentViewController:self.nowPlayingNav
							  animated:YES
							completion:^{}];
}

- (void)presentMusicPlayer {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[AGMediaPlayerViewController sharedInstance]];
    [self.yearsNav presentViewController:nav
                                animated:YES
                              completion:NULL];
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
		
		if(comps.count == 1) {
			// phishod:///
			// nothing, just opening app
			
			return YES;
		}
		
        self.window.rootViewController = self.yearsNav;
		[yearsNav popToRootViewControllerAnimated:NO];
		
		if(comps.count == 2) {
			// phishod:///:show_date
			// open to date
			
			PhishinShow *show = PhishinShow.alloc.init;
			show.date = comps[1];
			ShowViewController *showvc = [[ShowViewController alloc] initWithShow:show];
			
			[yearsNav pushViewController:showvc
								animated:NO];
		}
		else if(comps.count == 3) {
			// phishod:///:show_date/:track_id
			// open to track

			PhishinShow *show = PhishinShow.alloc.init;
			show.date = comps[1];
			ShowViewController *showvc = [[ShowViewController alloc] initWithShow:show];
			showvc.autoplay = YES;
			showvc.autoplayTrackId = [comps[2] integerValue];
			
			[yearsNav pushViewController:showvc
								animated:NO];
		}
		else if(comps.count == 4 || comps.count == 5) {
			// phishod:///:show_date/:track_id/3[/20]
			// open to 3[:20] on light
			NSTimeInterval position = [comps[3] integerValue] * 60;
			
			if(comps.count == 5)  {
				position += [comps[4] integerValue];
			}
			
			PhishinShow *show = PhishinShow.alloc.init;
			show.date = comps[1];
			ShowViewController *showvc = [[ShowViewController alloc] initWithShow:show];
			showvc.autoplay = YES;
			showvc.autoplayTrackId = [comps[2] integerValue];
			showvc.autoplaySeekLocation = position;
			
			[yearsNav pushViewController:showvc
								animated:NO];
		}
		
		return YES;
	}
	
	return NO;
}

@end
