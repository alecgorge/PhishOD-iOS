//
//  AppDelegate.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <JASidePanels/JASidePanelController.h>

#import "MenuPanel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (instancetype)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) JASidePanelController *panels;
@property (nonatomic) MenuPanel *menuPanel;
@property (nonatomic) UINavigationController *nowPlayingNav;

@property UINavigationController *yearsNav;
@property UITabBarController *tabBar;

@property PhishinShow *currentlyPlayingShow;

@property (nonatomic) BOOL shouldShowNowPlaying;
@property (nonatomic) BOOL isNowPlayingVisible;

- (void)toggleNowPlaying;
- (void)showNowPlaying;



@end
