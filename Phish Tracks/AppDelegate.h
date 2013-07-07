//
//  AppDelegate.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "EventInterceptWindow.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate, EventInterceptWindowDelegate>

@property (strong, nonatomic) EventInterceptWindow *window;
@property UINavigationController *yearsNav;
@property UITabBarController *tabBar;

@property (nonatomic) BOOL shouldShowNowPlaying;
@property (nonatomic) BOOL isNowPlayingVisible;

- (void)toggleNowPlaying;
- (void)showNowPlaying;

@end
