//
//  PTSHeatmapQuery.m
//  PhishOD
//
//  Created by Alexander Bird on 10/16/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PTSHeatmapQuery.h"
#import "PhishTracksStats.h"

@implementation PTSHeatmapQuery

- (id)initWithEntity:(NSString *)entity timeframe:(NSString *)timeframe filter:(NSString *)filterVal
{
	if (self = [super init]) {
		self.entity = entity;
		self.timeframe = timeframe;
		self.timezone = [PhishTracksStats tzOffset];
		self.filter = filterVal;
	}

	return self;
}

- (NSDictionary *)asParams
{
	NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:5];
	[query setValue:self.entity forKey:@"entity"];
	[query setValue:self.timeframe forKey:@"timeframe"];
	[query setValue:self.timezone forKey:@"timezome"];
	[query setValue:self.filter forKey:@"filter"];

	return @{ @"heatmap_query": query };
}

@end
