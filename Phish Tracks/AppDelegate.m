//
//  AppDelegate.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AppDelegate.h"
#import "YearsViewController.h"
#import "NowPlayingViewController.h"
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
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.shouldShowNowPlaying = NO;
	[[NowPlayingViewController sharedInstance] viewDidLoad];
    
	self.tabBar = [[UITabBarController alloc] init];
	
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

- (void)nowPlaying {
	NowPlayingViewController *nowPlaying = [NowPlayingViewController sharedInstance];
	[self.tabBar presentModalViewController:nowPlaying
								   animated:YES];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteControlEventReceived"
														object:event];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
