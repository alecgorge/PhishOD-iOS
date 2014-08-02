//
//  PhishinVenue.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinVenue.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>

@implementation PhishinVenue

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict[@"id"] intValue];
		self.name = dict[@"name"];
		
		if(dict[@"past_names"]
		&& ![dict[@"past_names"] isKindOfClass:[NSNull class]]) {
			self.past_names = dict[@"past_names"];
		}
		else {
			self.past_names = @"";
		}
		
		if(![dict[@"latitude"] isKindOfClass:[NSNull class]])
			self.latitude = [dict[@"latitude"] floatValue];
		
		if(![dict[@"longitude"] isKindOfClass:[NSNull class]])
			self.longitude = [dict[@"longitude"] floatValue];
		
		self.shows_count = [dict[@"shows_count"] intValue];
		self.location = dict[@"location"];
		self.slug = dict[@"slug"];
		
		if(!dict[@"show_dates"]) {
			self.show_dates = @[];
			self.show_ids = @[];
		}
		else {
			self.show_dates = dict[@"show_dates"];
			self.show_ids = dict[@"show_ids"];
		}
    }
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

@end
