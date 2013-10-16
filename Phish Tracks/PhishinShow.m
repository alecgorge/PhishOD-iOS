//
//  PhishinShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinShow.h"

@implementation PhishinShow

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
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

@end
