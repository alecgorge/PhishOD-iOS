//
//  PhishinYear.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinYear.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>
#import <EGOCache/EGOCache.h>

@implementation PhishinYear

- (BOOL)isEqualToPhishinYear:(PhishinYear *)year {
    return year && year.year == self.year && year.shows.count == self.shows.count;
}

- (NSString *)cacheKey {
    return [PhishinYear cacheKeyForYear:self.year];
}

- (PhishinYear *)cache {
    if(!self.year) {
        return nil;
    }
    
    [EGOCache.globalCache setObject:self
                             forKey:self.cacheKey];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self autoDecode:aDecoder];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

+ (NSString *)cacheKeyForYear:(NSString *)year {
    return [@"phishin.year." stringByAppendingString:year];
}

+ (PhishinYear *)loadYearFromCacheForYear:(NSString *)year {
    return (PhishinYear *)[EGOCache.globalCache objectForKey:[self cacheKeyForYear:year]];
}

@end
