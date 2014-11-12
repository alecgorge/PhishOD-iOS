//
//  PTSHeatmapResults.h
//  PhishOD
//
//  Created by Alexander Bird on 10/16/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSHeatmap : NSObject <NSCoding>

@property NSString *entity;
@property NSString *timeframe;
@property NSString *timezone;
@property NSInteger timezoneOffset;
@property NSString *absoluteTimeframeStart;
@property NSString *absoluteTimeframeEnd;
@property NSInteger userId;
@property NSString *username;
@property NSDictionary *heatmap;

- (id)initWithDictionary:(NSDictionary *)responseDict;
- (NSString *)description;

#pragma mark - Getting Heatmap data

- (float)floatValueForKey:(NSString *)key;

@end
