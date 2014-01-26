//
//  PhishTracksStatsFavoritePopover.h
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsFavoritePopover : NSObject<UIActionSheetDelegate>

+ (instancetype)sharedInstance;

- (void)showFromBarButtonItem:(UIView*)item inView:(UIView *)view;

@end
