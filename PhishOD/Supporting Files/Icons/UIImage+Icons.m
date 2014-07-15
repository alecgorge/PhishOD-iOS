//
//  UIImage+Icons.m
//  Phish Tracks
//
//  Created by Rudd Fawcett on 7/13/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "UIImage+Icons.h"

@implementation UIImage (Icons)

+ (instancetype)forwardIcon {
    return [UIImage imageNamed:@"forward-icon"];
}

+ (instancetype)forwardIconWhite {
    return [UIImage imageNamed:@"forward-icon-white"];
}

+ (instancetype)heartIconWhite {
    return [UIImage imageNamed:@"heart-icon-white"];
}

+ (instancetype)pauseIcon {
    return [UIImage imageNamed:@"pause-icon"];
}

+ (instancetype)pauseIconWhite {
    return [UIImage imageNamed:@"pause-icon-white"];
}

+ (instancetype)playIcon {
    return [UIImage imageNamed:@"play-icon"];
}

+ (instancetype)playIconWhite {
    return [UIImage imageNamed:@"play-icon-white"];
}

+ (instancetype)rewindIcon {
    return [UIImage imageNamed:@"rewind-icon"];
}

+ (instancetype)rewindIconWhite {
    return [UIImage imageNamed:@"rewind-icon-white"];
}

+ (instancetype)settingsNavigationIcon {
    return [UIImage imageNamed:@"settings-navigation-icon"];
}

@end
