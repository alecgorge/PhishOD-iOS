//
//  NowPlayingViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BeamMusicPlayerViewController/BeamMusicPlayerViewController.h>

@interface NowPlayingViewController : BeamMusicPlayerViewController

+ (NowPlayingViewController *)sharedInstance;

@end
