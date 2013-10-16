//
//  PhishinTour.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinTour.h"

@implementation PhishinTour

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict[@"id"] intValue];
		self.name = dict[@"name"];
		self.shows_count = [dict[@"shows_count"] intValue];

		self.starts_on = dict[@"starts_on"];
		self.ends_on = dict[@"ends_on"];
		self.slug = dict[@"slug"];
		
		self.shows = @[];
		
		if(dict[@"shows"]) {
			self.shows = [dict[@"shows"] map:^id(id object) {
				return [[PhishinShow alloc] initWithDictionary:object];
			}];
		}
    }
    return self;
}

- (NSString *)prettyDuration {
	return [NSString stringWithFormat:@"%@ – %@", self.starts_on, self.ends_on];
}

@end
