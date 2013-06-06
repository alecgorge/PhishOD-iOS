//
//  AppDelegate.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property UINavigationController *yearsNav;
@property UITabBarController *tabBar;

@property (nonatomic) BOOL shouldShowNowPlaying;

@end
