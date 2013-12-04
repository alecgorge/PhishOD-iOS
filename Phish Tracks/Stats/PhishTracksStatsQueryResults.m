//
//  PhishTracksStatsQueryResult.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsQueryResults.h"
#import "PhishTracksStatsStat.h"

@implementation PhishTracksStatsQueryResults

- (id)initWithDictionary:(NSDictionary *)responseDict {
	if (self = [super init]) {
		self.entity = responseDict[@"entity"];
		self.timeframe = responseDict[@"timeframe"];
		self.timezone = responseDict[@"timezone"];
		self.timezoneOffset = [responseDict[@"timezone_offset"] integerValue];

		id absoluteTimeframe = responseDict[@"absolute_timeframe"];
		if (absoluteTimeframe) {
			self.absoluteTimeframeStart = absoluteTimeframe[@"start"];
			self.absoluteTimeframeEnd = absoluteTimeframe[@"end"];
		}

		id userDict = responseDict[@"user"];
		if (userDict) {
			self.userId = [userDict[@"id"] integerValue];
			self.username = userDict[@"username"];
		}

		self.scalarStatCount = 0;
		self.stats = [NSMutableArray arrayWithCapacity:[responseDict[@"stats"] count]];

		for (id statDict in responseDict[@"stats"]) {
			PhishTracksStatsStat *stat = [[PhishTracksStatsStat alloc] initWithDictionary:statDict];
			[self.stats addObject:stat];

			if (stat.isScalar) {
				self.scalarStatCount++;
			}
		}

		self.nonScalarStatCount = self.stats.count - self.scalarStatCount;
	}

	return self;
}

- (PhishTracksStatsStat *)getStatAtIndex:(NSInteger)index
{
	return (PhishTracksStatsStat *)[self.stats objectAtIndex:index];

}

- (NSString *)description {
	return [NSString stringWithFormat: @"PhishTracksStatsQueryResult:\n"
			                            "  entity = %@\n"
			                            "  timeframe = %@\n"
										"  timezone = %@\n"
										"  timezoneOffset = %ld\n"
										"  absoluteTimeframeStart = %@\n"
			                            "  absoluteTimeframeEnd = %@\n"
			                            "  userId = %ld\n"
			                            "  username = %@\n"
			                            "  stats = %@",
			self.entity, self.timeframe, self.timezone, (long)self.timezoneOffset, self.absoluteTimeframeStart,
            self.absoluteTimeframeEnd, (long)self.userId, self.username, _stats];
}

@end
