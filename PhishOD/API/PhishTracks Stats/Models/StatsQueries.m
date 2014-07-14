//
//  StatsQueries.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StatsQueries.h"

static NSDictionary *stats;

@implementation StatsQueries

+ (PhishTracksStatsQuery *)predefinedStatQuery:(StatsPredefinedQueryNames)name
{
	if (!stats)
		stats = [NSMutableDictionary dictionary];

	NSString *nameObj = [NSString stringWithFormat:@"%ld", (long)name];

	if ([stats hasKey:nameObj])
		return [stats objectForKey:nameObj];

	PhishTracksStatsQuery *query = nil;

	if (name == kUserAllTimeScalarStats) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"catalog_progress"];
	}
	else if (name == kUserAllTimeTopTracks) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalAllTime) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_count"];
		[query addStatWithName:@"catalog_progress"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalToday) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"today"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisHour) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"this_hour"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisWeek) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"this_week"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisMonth) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"this_month"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisYear) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"this_year"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"duration_sum_fmt"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTracksOver20Min) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
        [query addFilterWithAttrName:@"track_duration" filterOperator:@"gte" attrValue:@1200000];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTopSets) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"sets" timeframe:@"all_time"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTopShows) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"shows" timeframe:@"all_time"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_count"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTopTours) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tours" timeframe:@"all_time"];
		[query addStatWithName:@"total_count"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTopVenues) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"venues" timeframe:@"all_time"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_count"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
    else if (name == kGlobalTopYears) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"years" timeframe:@"all_time"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}

	if (query) {
		[stats setValue:query forKey:nameObj];
		return query;
	}
	else
		return nil;
}

+ (PhishTracksStatsQuery *)topTracksInYearsQuery:(NSArray *)years
{
    PhishTracksStatsQuery *query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
    [query addFilterWithAttrName:@"year" filterOperator:@"in" attrValue:years];
    [query addStatWithName:@"play_count"];
    [query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
    
    return query;
}

+ (PhishTracksStatsQuery *)topTracksForEraQuery:(NSString *)era
{
    PhishTracksStatsQuery *query = [[PhishTracksStatsQuery alloc] initWithEntity:@"tracks" timeframe:@"all_time"];
    [query addFilterWithAttrName:@"era" filterOperator:@"eq" attrValue:era];
    [query addStatWithName:@"play_count"];
    [query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
    
    return query;
}

@end
