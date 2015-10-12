//
//  PhishAlbumArtCache.m
//  PhishOD
//
//  Created by Alec Gorge on 10/7/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import "PhishAlbumArtCache.h"

#import <ChameleonFramework/Chameleon.h>
#import <EDColor/EDColor.h>

#import "PhishAlbumArts.h"

NSArray *PHODYearColors = nil;

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
        
        PHODYearColors = @[
            [UIColor colorWithHue:0.21666666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.25 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.2833333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.31666666666666665 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.35 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.38333333333333336 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.4166666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.45 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.48333333333333334 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.5166666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.55 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.5833333333333334 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.6166666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.65 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.6833333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.7166666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.75 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.7833333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.8166666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.85 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.8833333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.9166666666666666 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.95 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.9833333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.016666666666666666 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.05 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.08333333333333333 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.11666666666666667 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.15 saturation:0.65 lightness:.6 alpha:1.0],
            [UIColor colorWithHue:0.18333333333333332 saturation:0.65 lightness:.6 alpha:1.0],
        ];
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
    NSString *p = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:[p stringByAppendingPathComponent:@"ImageTables"]
                                               error:&err];
    
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
        
        NSInteger year = [[date substringToIndex:4] integerValue];
        NSInteger index = MAX(0, year - 1987);
        
        UIColor *baseColor = [PHODYearColors[index] darken:0.05];
        
        NSInteger month = [[date substringWithRange:NSMakeRange(5, 2)] integerValue];
        
        baseColor = [baseColor offsetWithHue:0.0f
                                  saturation:((month - 1) *  2) / 100.0f
                                   lightness:((month - 1) * -2) / 100.0f
                                       alpha:1.0f];
        
        NSInteger day = [[date substringWithRange:NSMakeRange(8, 2)] integerValue];
        
        UIGraphicsBeginImageContext(CGSizeMake(768, 768));
        
        BOOL allSame = YES;
        
        if(!allSame && day % 4 == 1) {
            [PhishAlbumArts drawShatterExplosionWithBaseColor:baseColor
                                                         date:date
                                                        venue:venue
                                                  andLocation:location];
        }
        else if(!allSame && day % 4 == 2) {
            [PhishAlbumArts drawRandomFlowersWithBaseColor:baseColor
                                                         date:date
                                                        venue:venue
                                                  andLocation:location];
        }
        else if(!allSame && day % 4 == 3) {
            [PhishAlbumArts drawSplashWithBaseColor:baseColor
                                                         date:date
                                                        venue:venue
                                                  andLocation:location];
        }
        else if(allSame || day % 4 == 0) {
            [PhishAlbumArts drawCityGlittersWithBaseColor:baseColor
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
