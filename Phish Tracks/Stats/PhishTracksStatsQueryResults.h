//
//  PhishTracksStatsQueryResult.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishTracksStatsStat.h"

@interface PhishTracksStatsQueryResults : NSObject

@property NSString *entity;
@property NSString *timeframe;
@property NSString *timezone;
@property NSInteger timezoneOffset;
@property NSString *absoluteTimeframeStart;
@property NSString *absoluteTimeframeEnd;
@property NSInteger userId;
@property NSString *username;
@property NSMutableArray *stats;
@property NSInteger scalarStatCount;
@property NSInteger nonScalarStatCount;

- (id)initWithDict:(NSDictionary *)responseDict;
- (NSString *)description;

- (PhishTracksStatsStat *)getStatAtIndex:(NSInteger)index;

@end
