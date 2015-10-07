//
//  PhishAlbumArtCache.m
//  PhishOD
//
//  Created by Alec Gorge on 10/7/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import "PhishAlbumArtCache.h"

static NSString *PHODImageFormatSmall = @"com.alecgorge.ios.phishod.albumart.small";
static NSString *PHODImageFormatMedium = @"com.alecgorge.ios.phishod.albumart.medium";
static NSString *PHODImageFormatFull = @"com.alecgorge.ios.phishod.albumart.full";
static NSString *PHODImageFamily = @"com.alecgorge.ios.phishod.albumart";

@implementation PhishAlbumArtCache

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedFoo;
    dispatch_once(&once, ^ {
        sharedFoo = PhishAlbumArtCache.new;
    });
    return sharedFoo;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupImageCache];
    }
}

- (void)setupImageCache {
    FICImageFormat *small = [[FICImageFormat alloc] init];
    small.name = PHODImageFormatSmall;
    small.family = PHODImageFamily;
    small.style = FICImageFormatStyle32BitBGR;
    small.imageSize = CGSizeMake(112 * 2, 112 * 2);
    small.maximumCount = 250;
    small.devices = FICImageFormatDevicePhone;
    small.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *medium = [[FICImageFormat alloc] init];
    medium.name = PHODImageFormatMedium;
    medium.family = PHODImageFamily;
    medium.style = FICImageFormatStyle32BitBGR;
    medium.imageSize = CGSizeMake(512, 512);
    medium.maximumCount = 250;
    medium.devices = FICImageFormatDevicePhone;
    medium.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *full = [[FICImageFormat alloc] init];
    full.name = PHODImageFormatMedium;
    full.family = PHODImageFamily;
    full.style = FICImageFormatStyle32BitBGR;
    full.imageSize = CGSizeMake(768, 768);
    full.maximumCount = 3;
    full.devices = FICImageFormatDevicePhone;
    full.protectionMode = FICImageFormatProtectionModeNone;
    
    NSArray *imageFormats = @[small, medium, full];
    
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    sharedImageCache.delegate = self;
    sharedImageCache.formats = imageFormats;
}

@end
