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
	kUserAllTimeTopTracks   = 1,
	kUserAllTimeScalarStats = 2,
	kGlobalAllTime          = 3,
	kGlobalToday            = 4,
	kGlobalThisHour         = 5,
	kGlobalThisWeek         = 6,
	kGlobalThisMonth        = 7,
	kGlobalThisYear         = 8

} StatsPredefinedQueryNames;

@interface StatsQueries : NSObject

+ (PhishTracksStatsQuery *)predefinedStatQuery:(StatsPredefinedQueryNames)name;

@end
