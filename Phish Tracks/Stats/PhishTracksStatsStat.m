//
//  PhishTracksStatsStat.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsStat.h"
#import "PhishTracksStatsPlayEvent.h"

@implementation PhishTracksStatsStat

- (id)initWithDictionary:(NSDictionary *)dict
{
	if (self = [super init]) {
		self.name = dict[@"name"];
		self.prettyName = dict[@"pretty_name"];
		id rawValue = dict[@"value"];

		if ([rawValue isKindOfClass:[NSArray class]] || [rawValue isKindOfClass:[NSDictionary class]]) {
			self.isScalar = NO;
			[self initPlayEventsWithValue:rawValue];
		}
		else {
			self.isScalar = YES;
			self.value = rawValue;
		}
	}

	return self;
}

- (void)initPlayEventsWithValue:(id)rawValue
{
	if ([rawValue isKindOfClass:[NSArray class]]) {
		// Assume that if the rawValue is an array, it's an array of play_events
		NSMutableArray *playEvents = [NSMutableArray arrayWithCapacity:[rawValue count]];

		for (id val in rawValue) {
			NSDictionary *playDict = [val objectForKey:@"play_event"];

			if (playDict) {
				[playEvents addObject:[[PhishTracksStatsPlayEvent alloc] initWithDictionary:playDict]];
			}
			else {
				CLS_LOG(@"expected play_event in stat.value array. got %@", val);
			}
		}

		self.value = playEvents;
	}
	else if ([rawValue isKindOfClass:[NSDictionary class]] && [rawValue objectForKey:@"play_event"]) {
		self.value = [[PhishTracksStatsPlayEvent alloc] initWithDictionary:rawValue];
	}
}

- (NSInteger)count
{
	if (self.isScalar) {
		return 1;
	}
	else {
		return [self.value count];
	}
}

- (NSString *)valueAsString
{
	return [NSString stringWithFormat:@"%@", self.value];
//	return [NSString stringWithFormat:@"VALUE", self.value];
}

@end
