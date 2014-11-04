//
//  PhishinYear.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishinYear : NSObject<NSCoding>

@property (nonatomic) NSString *year;
@property (nonatomic) NSArray *shows;

- (BOOL)isEqualToPhishinYear:(PhishinYear *)year;

- (PhishinYear *)cache;

+ (NSString *)cacheKeyForYear:(NSString *)year;
+ (PhishinYear *)loadYearFromCacheForYear:(NSString *)year;

@end
