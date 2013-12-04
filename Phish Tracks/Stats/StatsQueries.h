//
//  StatsQueries.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishTracksStatsQuery.h"

typedef enum {
	kUserAllTimeTopTracks,
	kUserAllTimeScalarStats,
	kGlobalAllTime,
	kGlobalToday,
	kGlobalThisHour,
	kGlobalThisWeek,
	kGlobalThisMonth,
	kGlobalThisYear,
    kGlobalTracksOver20Min,
    kGlobalTopSets,
    kGlobalTopShows,
    kGlobalTopTours,
    kGlobalTopVenues,
    kGlobalTopYears,
} StatsPredefinedQueryNames;

@interface StatsQueries : NSObject

+ (PhishTracksStatsQuery *)predefinedStatQuery:(StatsPredefinedQueryNames)name;
+ (PhishTracksStatsQuery *)topTracksInYearsQuery:(NSArray *)years;
+ (PhishTracksStatsQuery *)topTracksForEraQuery:(NSString *)era;

@end
