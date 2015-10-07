//
//  PhishAlbumArtCache.h
//  PhishOD
//
//  Created by Alec Gorge on 10/7/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FastImageCache/FICImageCache.h>

NSString *PHODImageFormatSmall;
NSString *PHODImageFormatMedium;
NSString *PHODImageFormatFull;

@interface PhishAlbumArtCache : NSObject

+(instancetype)sharedInstance;

@end
