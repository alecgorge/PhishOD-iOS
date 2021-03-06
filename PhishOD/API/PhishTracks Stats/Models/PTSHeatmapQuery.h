//
//  PTSHeatmapQuery.h
//  PhishOD
//
//  Created by Alexander Bird on 10/16/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTSHeatmapQuery : NSObject

@property NSString *entity;
@property NSString *timeframe;
@property NSString *timezone;
@property NSString *filter;


#pragma mark - Initizliationses

- (id)initWithAutoTimeframeAndEntity:(NSString *)entity filter:(NSString *)filterVal;

#pragma mark - Serialization

- (NSDictionary *)asParams;
- (NSString *)cacheKey;

@end
