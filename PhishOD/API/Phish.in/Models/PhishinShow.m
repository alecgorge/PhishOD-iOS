//
//  PhishinShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinShow.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>
#import <EGOCache/EGOCache.h>

@implementation PhishinShow

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
		if([dict isKindOfClass:NSNull.class] || [dict[@"missing"] boolValue]) {
			self.missing = YES;
			return self;
		}
		
        self.id = [dict[@"id"] intValue];
		self.date = dict[@"date"];
		self.duration = [dict[@"duration"] integerValue];
		self.incomplete = [dict[@"incomplete"] boolValue];
		self.missing = [dict[@"missing"] boolValue];
		self.sbd = [dict[@"sbd"] boolValue];
		self.remastered = [dict[@"remastered"] boolValue];
		self.tour_id = [dict[@"tour_id"] intValue];
		self.venue_id = [dict[@"venue_id"] intValue];
		self.likes_count = [dict[@"likes_count"] intValue];
		self.taperNotes = [dict[@"taper_notes"] isKindOfClass:NSNull.class] ? nil : dict[@"taper_notes"];
		
		if (dict[@"venue"]) {
			self.venue = [[PhishinVenue alloc] initWithDictionary:dict[@"venue"]];
		}
		else {
			self.venue_name = dict[@"venue_name"];
			self.location = dict[@"location"];
		}
		
		if (dict[@"tracks"]) {
			self.tracks = [dict[@"tracks"] map:^id(id object) {
				return [[PhishinTrack alloc] initWithDictionary:object andShow:self];
			}];
			
			self.sets = [[dict[@"tracks"] valueForKeyPath:@"@distinctUnionOfObjects.set"] sortedArrayUsingSelector:@selector(compare:)];
			self.sets = [self.sets map:^id(id object) {
				NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.set == %@", object];

				NSString *name;
				if([object caseInsensitiveCompare:@"E"] == NSOrderedSame) {
					name = @"Encore";
				}
				else {
					name = [@"Set " stringByAppendingString:object];
				}
				
				return [[PhishinSet alloc] initWithTitle:name
											   andTracks:[self.tracks filteredArrayUsingPredicate:pred]];
			}];
		}
		else {
			self.tracks = @[];
			self.sets = @[];
		}
    }
    return self;
}

- (NSString *)venue_name {
	if (_venue_name) {
		return _venue_name;
	}
	
	return self.venue.name;
}

- (NSString *)location {
	if (_location) {
		return _location;
	}
	
	return self.venue.location;
}

- (NSString *)fullLocation {
	return [self.location stringByAppendingFormat:@" - %@", self.venue_name];
}

- (NSString *)cacheKey {
	return [PhishinShow cacheKeyForShowDate:self.date];
}

- (PhishinShow *)cache {
	[EGOCache.globalCache setObject:self
							 forKey:self.cacheKey];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		[self autoDecode:aDecoder];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
	[self autoEncodeWithCoder:coder];
}

+ (NSString *)cacheKeyForShowDate:(NSString *)date {
	return [@"phishin.show." stringByAppendingString:date];
}

+ (PhishinShow *)loadShowFromCacheForShowDate:(NSString *)date {
	return (PhishinShow *)[EGOCache.globalCache objectForKey:[self cacheKeyForShowDate:date]];
}

@end
