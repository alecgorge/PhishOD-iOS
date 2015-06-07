//
//  NowPlayingBarViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NowPlayingBarViewController : UIViewController<UIGestureRecognizerDelegate>

+ (instancetype)sharedInstance;

@property BOOL shouldShowBar;

@end
