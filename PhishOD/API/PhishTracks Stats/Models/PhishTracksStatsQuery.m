//
//  PhishTracksStatsQuery.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsQuery.h"
#import "PhishTracksStats.h"

@implementation PhishTracksStatsQuery

- (id)initWithEntity:(NSString *)entity timeframe:(NSString *)timeframe
{
	if (self = [super init]) {
		self.entity = entity;
		self.timeframe = timeframe;
		self.timezone = [PhishTracksStats tzOffset];
		self.filters = [NSMutableArray arrayWithCapacity:10];
		self.stats = [NSMutableArray arrayWithCapacity:10];
	}

	return self;
}

- (void)addFilterWithAttrName:(NSString *)attrName filterOperator:(NSString *)filterOperator attrValue:(id)attrValue;
{
	NSDictionary *newFilter = @{ @"attr_name": attrName, @"operator": filterOperator, @"attr_value": attrValue };
	[self.filters addObject:newFilter];
}

- (void)addStatWithName:(NSString *)name;
{
	[self addStatWithName:name andOptions:nil];

}

- (void)addStatWithName:(NSString *)name andOptions:(NSDictionary *)options;
{
	NSDictionary *newStat = nil;

	if (options) {
		newStat = [options mutableCopy];
		[newStat setValue:name forKey:@"name"];
	}
	else {

		newStat = @{ @"name": name };
	}

	[self.stats addObject:newStat];
}

- (NSDictionary *)asParams
{
	NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:5];
	[query setValue:self.entity forKey:@"entity"];
	[query setValue:self.timeframe forKey:@"timeframe"];
	[query setValue:self.timezone forKey:@"timezome"];

	if (self.filters.count > 0) {
		[query setValue:self.filters forKey:@"filters"];
	}

	if (self.stats.count > 0) {
		[query setValue:self.stats forKey:@"stats"];
	}

	return @{ @"stats_query": query };
}

@end
