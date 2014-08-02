//
//  PhishinShow.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishinVenue.h"
#import "PhishinTrack.h"
#import "PhishinSet.h"

#import "PhishNetSetlist.h"

@interface PhishinShow : NSObject<NSCoding>

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic) int id;
@property (nonatomic) NSString *date;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) BOOL incomplete;
@property (nonatomic) BOOL missing;
@property (nonatomic) BOOL sbd;
@property (nonatomic) BOOL remastered;
@property (nonatomic) int tour_id;
@property (nonatomic) int venue_id;
@property (nonatomic) int likes_count;

@property (nonatomic) NSString *venue_name;
@property (nonatomic) NSString *location;
@property (nonatomic) NSArray *tags;
@property (nonatomic) PhishinVenue *venue;

@property (nonatomic) NSArray *sets;
@property (nonatomic) NSArray *tracks;
@property (nonatomic) NSString *taperNotes;

@property (nonatomic) PhishNetSetlist *setlist;

@property (nonatomic, readonly) NSString *fullLocation;
@property (nonatomic, readonly) NSString *cacheKey;

- (PhishinShow *)cache;

+ (NSString *)cacheKeyForShowDate:(NSString *)date;
+ (PhishinShow *)loadShowFromCacheForShowDate:(NSString *)date;

@end
