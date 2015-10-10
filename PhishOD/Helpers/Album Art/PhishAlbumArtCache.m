//
//  PhishAlbumArtCache.m
//  PhishOD
//
//  Created by Alec Gorge on 10/7/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import "PhishAlbumArtCache.h"

#import <ChameleonFramework/Chameleon.h>

#import "PhishAlbumArts.h"

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
    return self;
}

- (void)setupImageCache {
    FICImageFormat *small = [[FICImageFormat alloc] init];
    small.name = PHODImageFormatSmall;
    small.family = PHODImageFamily;
    small.style = FICImageFormatStyle32BitBGR;
    small.imageSize = CGSizeMake(112 * 2, 112 * 2);
    small.maximumCount = 250;
    small.devices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    small.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *medium = [[FICImageFormat alloc] init];
    medium.name = PHODImageFormatMedium;
    medium.family = PHODImageFamily;
    medium.style = FICImageFormatStyle32BitBGR;
    medium.imageSize = CGSizeMake(512, 512);
    medium.maximumCount = 250;
    medium.devices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    medium.protectionMode = FICImageFormatProtectionModeNone;
    
    FICImageFormat *full = [[FICImageFormat alloc] init];
    full.name = PHODImageFormatFull;
    full.family = PHODImageFamily;
    full.style = FICImageFormatStyle32BitBGR;
    full.imageSize = CGSizeMake(768, 768);
    full.maximumCount = 3;
    full.devices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    full.protectionMode = FICImageFormatProtectionModeNone;
    
    NSArray *imageFormats = @[small, medium, full];
    
    [self.sharedCache reset];
    self.sharedCache.delegate = self;
    self.sharedCache.formats = imageFormats;
}

- (FICImageCache *)sharedCache {
    return FICImageCache.sharedImageCache;
}

- (void)imageCache:(FICImageCache *)imageCache
wantsSourceImageForEntity:(id<FICEntity>)entity
    withFormatName:(NSString *)formatName
   completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Fetch the desired source image by making a network request
        NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:requestURL
                                                    resolvingAgainstBaseURL:NO];
        
        NSString *date = [self valueForKey:@"date"
                            fromQueryItems:urlComponents.queryItems];
        NSString *venue = [self valueForKey:@"venue"
                             fromQueryItems:urlComponents.queryItems];
        NSString *location = [self valueForKey:@"location"
                                fromQueryItems:urlComponents.queryItems];
        
        UIColor *baseColor = [[UIColor randomFlatColor] darkenByPercentage:.1];
        
        UIGraphicsBeginImageContext(CGSizeMake(768, 768));
        
        if(arc4random_uniform(2)) {
            [PhishAlbumArts drawShatterExplosionWithBaseColor:baseColor
                                                         date:date
                                                        venue:venue
                                                  andLocation:location];
        }
        else {
            [PhishAlbumArts drawRandomFlowersWithBaseColor:baseColor
                                                      date:date
                                                     venue:venue
                                               andLocation:location];
        }

        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(image);
        });
    });
}

- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems
                                  filteredArrayUsingPredicate:predicate]
                                 firstObject];
    return queryItem.value;
}

@end
