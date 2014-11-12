//
//  PTSHeatmapResults.m
//  PhishOD
//
//  Created by Alexander Bird on 10/16/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PTSHeatmap.h"

@implementation PTSHeatmap

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

		NSMutableDictionary *tmpHeatmap = [NSMutableDictionary dictionary];

		for (id slugKey in responseDict[@"heatmap"]) {
			// convert types in the json obj
			NSMutableDictionary *value = [NSMutableDictionary dictionaryWithDictionary:[responseDict[@"heatmap"] objectForKey:slugKey]];
			NSString *hmVal = value[@"value"];
			[value setObject:@([hmVal floatValue]) forKey:@"value"];
			[tmpHeatmap setObject:[NSDictionary dictionaryWithDictionary:value] forKey:slugKey];
		}
		
		self.heatmap = [NSDictionary dictionaryWithDictionary:tmpHeatmap];
	}

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat: @"PTSHeatmapResult:\n"
			                            "  entity = %@\n"
			                            "  timeframe = %@\n"
										"  timezone = %@\n"
										"  timezoneOffset = %ld\n"
										"  absoluteTimeframeStart = %@\n"
			                            "  absoluteTimeframeEnd = %@\n"
			                            "  userId = %ld\n"
			                            "  username = %@\n"
			                            "  heatmap = %@",
			self.entity, self.timeframe, self.timezone, (long)self.timezoneOffset, self.absoluteTimeframeStart,
            self.absoluteTimeframeEnd, (long)self.userId, self.username, _heatmap];
}


- (float)floatValueForKey:(NSString *)key {
	NSDictionary *entry = self.heatmap[key];
	
	if (entry) {
		return [entry[@"value"] floatValue];
	}
	
	// default value
	return 0.0f;
}

@end
