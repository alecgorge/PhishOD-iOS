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
	if (!stats) {
		stats = [NSMutableDictionary dictionaryWithCapacity:20];
	}

	NSString *nameObj = [NSString stringWithFormat:@"%ld", (long)name];

	if ([stats hasKey:nameObj]) {
		return [stats objectForKey:nameObj];
	}

	PhishTracksStatsQuery *query = nil;

	if (name == kUserAllTimeScalarStats) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"all_time"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"catalog_progress"];
	}
	else if (name == kUserAllTimeTopTracks) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"all_time"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalAllTime) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"all_time"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"track_count"];
		[query addStatWithName:@"catalog_progress"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalToday) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"today"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisHour) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"this_hour"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisWeek) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"this_week"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisMonth) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"this_month"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}
	else if (name == kGlobalThisYear) {
		query = [[PhishTracksStatsQuery alloc] initWithEntity:@"track" timeframe:@"this_year"];
		[query addStatWithName:@"play_count"];
		[query addStatWithName:@"unique_count"];
		[query addStatWithName:@"total_time_formatted"];
		[query addStatWithName:@"play_count_ranking" andOptions:@{ @"limit": @100, @"offset": @0 }];
	}

	if (query) {
		[stats setValue:query forKey:nameObj];
		return query;
	}
	else
		return nil;
}

@end
