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
#import "PHODNewHomeViewController.h"
#import "PHODHistory.h"
#import "PHODTabbedHomeViewController.h"
#import "RLArtistsTableViewController.h"
#import "RLArtistTabViewController.h"
#import "HFPodDataManager.h"

#import <LastFm.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "PHODPersistence.h"
#import <GroundControl/NSUserDefaults+GroundControl.h>
#import <Instabug/Instabug.h>
#import <SDCloudUserDefaults/SDCloudUserDefaults.h>
#import <FlurrySDK/Flurry.h>

#import <PSUpdateApp/PSUpdateApp.h>

static AppDelegate *sharedDelegate;

static BOOL __haveSetup = NO;

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
	
	__haveSetup = YES;
	
    [Fabric with:@[CrashlyticsKit]];
#ifdef IS_PHISH
    [Flurry startSession:@"JJNX7YHMWM34SFD2GG8K"];
#else
    [Flurry startSession:@"4RGRH573MCY85Z5RJC2X"];
#endif
	
    [IGEvents setup];
    
	[AFNetworkActivityLogger.sharedLogger startLogging];
	
	// prevent LivePhish.com and Phish.net from logging passwords in plaintext
	AFNetworkActivityLogger.sharedLogger.filterPredicate = [NSPredicate predicateWithBlock:^BOOL(NSURLRequest *op, NSDictionary *bindings) {
		return [op.URL.query containsString:@"session.getUserToken"] || [op.URL.query containsString:@"passwd="];
	}];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *ptsServer = infoDictionary[@"StatsServer"];
	[PhishTracksStats setupWithAPIKey:IGThirdPartyKeys.sharedInstance.phishtracksStatsApiKey andBaseUrl:ptsServer];
	
    [SDCloudUserDefaults registerForNotifications];
    [NSUserDefaults.standardUserDefaults registerDefaultsWithURL:[NSURL URLWithString:@"http://phishod-config.app.alecgorge.com/app-config.plist"]];
	
	[self setupLastFM];
	[self setupCaching];
	[self setupAppearance];
	[self setupHeatmapSettings];
	[self setupBugshotKit];
	
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	self.shouldShowNowPlaying = NO;
	
    self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.alloc.init;
	
//	HomeViewController *years = [[HomeViewController alloc] init];
//    PHODNewHomeViewController *years = PHODNewHomeViewController.alloc.init;
//	self.yearsNav = [[UINavigationController alloc] initWithRootViewController:years];
//    self.yearsNav.delegate = self.navDelegate;
//	self.yearsNav.navigationBar.translucent = NO;

#ifdef IS_PHISH
	self.tabs = PHODTabbedHomeViewController.new;
	self.window.rootViewController = self.tabs;
#else
	RLArtistsTableViewController *vc = RLArtistsTableViewController.new;
	UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:vc];
	self.window.rootViewController = nav;
#endif
	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	[self checkForUpdates];
	
	[AFNetworkReachabilityManager.sharedManager startMonitoring];

    [UIApplication.sharedApplication beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    [self hydrateFromSavedState];
    
//    self.slideshowManager = [PHODSlideshowManager.alloc initWithWindow:self.window];
	
    return YES;
}

- (void)setupBugshotKit {
	[Instabug startWithToken:@"63c7015b6dfc0c9994d0bf7ae9af7a96"
			   captureSource:IBGCaptureSourceUIKit
			 invocationEvent:IBGInvocationEventShake];
	
	[Instabug setButtonsFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
	[Instabug setButtonsColor:[UIColor colorWithRed:(17/255.0) green:(138/255.0) blue:(114/255.0) alpha:1.0]];
	[Instabug setHeaderFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
	[Instabug setHeaderColor:[UIColor colorWithRed:(26/255.0) green:(188/255.0) blue:(156/255.0) alpha:1.0]];
	[Instabug setTextFontColor:[UIColor colorWithRed:(82/255.0) green:(83/255.0) blue:(83/255.0) alpha:1.0]];
	[Instabug setTextBackgroundColor:[UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1.0]];
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
		
		[UIButton appearance].tintColor = phishGreen;
		
        [UIBarButtonItem appearance].tintColor = white;
		
		[UISegmentedControl appearance].tintColor = phishGreen;
		
		[UITabBar appearance].tintColor = phishGreen;
	}
	else {
		[UINavigationBar appearance].tintColor = phishGreen;
	}

	[UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: white};
	
//	[UITableViewHeaderFooterView appearance].tintColor = lightPhishGreen;
}

- (UITabBar *)tabBar {
	return self.tabs.tabBar;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	if(IS_IPAD()) {
		return UIInterfaceOrientationMaskAll;
	}
	
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)setupCaching {
   [HFPodDataManager sharedInstance];
}

- (void)setupLastFM {
    if(IGThirdPartyKeys.sharedInstance.isLastFmEnabled) {
        LastFm.sharedInstance.apiKey = IGThirdPartyKeys.sharedInstance.lastFmApiKey;
        LastFm.sharedInstance.apiSecret = IGThirdPartyKeys.sharedInstance.lastFmApiSecret;
        LastFm.sharedInstance.session = [NSUserDefaults.standardUserDefaults stringForKey:@"lastfm_session_key"];
        LastFm.sharedInstance.username = [NSUserDefaults.standardUserDefaults stringForKey:@"lastfm_username_key"];
    }
}

- (void)setupHeatmapSettings {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"heatmaps.enabled"] == nil) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"heatmaps.enabled"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	if(!__haveSetup) {
		[self application:UIApplication.sharedApplication
didFinishLaunchingWithOptions:nil];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived"
														object:event];
    [self saveCurrentState];
}

- (void)nowPlaying {
	[self.window.rootViewController presentViewController:self.nowPlayingNav
							  animated:YES
							completion:^{}];
}

- (void)presentMusicPlayer {
    [self presentMusicPlayerWithComplete:nil];
}

- (void)presentMusicPlayerWithComplete:(void (^)(void))complete {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[AGMediaPlayerViewController sharedInstance]];
    [self.tabs presentViewController:nav
                            animated:YES
                          completion:complete];
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveCurrentState];
}

- (void)saveCurrentState {
	if([PHODHistory.sharedInstance addShow:self.currentlyPlayingShow]) {
		[PHODPersistence.sharedInstance setObject:PHODHistory.sharedInstance
                                           forKey:@"current.history"];
		
		dbug(@"history changed! caching.");
	}
}

- (void)hydrateFromSavedState {
//    AGAudioPlayerUpNextQueue *queue = (AGAudioPlayerUpNextQueue *)[EGOCache.globalCache objectForKey:@"current.queue"];
//    NSInteger pos = ((NSNumber*)[EGOCache.globalCache objectForKey:@"current.index"]).integerValue;
//    NSTimeInterval elapsed = ((NSNumber*)[EGOCache.globalCache objectForKey:@"current.progress"]).floatValue;
//    PhishinShow *show = (PhishinShow *)[EGOCache.globalCache objectForKey:@"current.show"];
//    PTSHeatmap *heatmap = (PTSHeatmap *)[EGOCache.globalCache objectForKey:@"current.show-heatmap"];
//
//    if(!(queue && queue.count > 0 && show)) {
//        return;
//    }
//
//    AGMediaPlayerViewController *player = AGMediaPlayerViewController.sharedInstance;
//	player.heatmap = heatmap;
//    [player replaceQueueWithItems:queue.queue
//                       startIndex:pos];
//	
////    [player play];
//	
//    if(elapsed != 0.0f) {
//        player.progress = elapsed;
//    }
//
//    [player pause];
//    
//    self.currentlyPlayingShow = show;
//    
//    [AGMediaPlayerViewController.sharedInstance viewWillAppear:NO];
//    
//    [self.navDelegate addBarToViewController:self.yearsNav.viewControllers.lastObject];
//    [self.navDelegate fixForViewController:self.yearsNav.viewControllers.lastObject];
}

@end
