//
//  PhishTracksStatsQuery.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsQuery : NSObject

@property NSString *entity;
@property NSString *timeframe;
@property NSString *timezone;
@property NSMutableArray *filters;
@property NSMutableArray *stats;

- (id)initWithEntity:(NSString *)entity timeframe:(NSString *)timeframe;

- (void)addFilterWithAttrName:(NSString *)attrName filterOperator:(NSString *)filterOperator attrValue:(id)attrValue;

- (void)addStatWithName:(NSString *)name;
- (void)addStatWithName:(NSString *)name andOptions:(NSDictionary *)options;
- (NSDictionary *)asParams;

@end
