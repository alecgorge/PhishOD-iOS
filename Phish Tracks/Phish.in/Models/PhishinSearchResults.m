//
//  PhishinSearchResults.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinSearchResults.h"

@implementation PhishinSearchResults

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if([self isNull:dict[@"show"]]) {
			self.show = @[];
		}
		else {
			self.show = @[[[PhishinShow alloc] initWithDictionary:dict[@"show"]]];
		}
		
        if([self isNull:dict[@"other_shows"]]) {
			self.other_shows = @[];
		}
		else {
			self.other_shows = [dict[@"other_shows"] map:^id(id object) {
				return [[PhishinShow alloc] initWithDictionary:object];
			}];
		}
		
        if([self isNull:dict[@"songs"]]) {
			self.songs = @[];
		}
		else {
			self.songs = [dict[@"songs"] map:^id(id object) {
				return [[PhishinSong alloc] initWithDictionary:object];
			}];
		}
		
        if([self isNull:dict[@"venues"]]) {
			self.venues = @[];
		}
		else {
			self.venues = [dict[@"venues"] map:^id(id object) {
				return [[PhishinVenue alloc] initWithDictionary:object];
			}];
		}
		
        if([self isNull:dict[@"tours"]]) {
			self.tours = @[];
		}
		else {
			self.tours = [dict[@"tours"] map:^id(id object) {
				return [[PhishinTour alloc] initWithDictionary:object];
			}];
		}
		
    }
    return self;
}

- (BOOL)isNull:(id)obj {
	if (obj == nil) {
		return YES;
	}
	
	if([obj isKindOfClass:[NSNull class]]) {
		return YES;
	}
	
	return NO;
}

- (NSArray *)allKeys {
	return @[@"show", @"other_shows", @"songs", @"venues", @"tours"];
}

- (NSArray *)allowedKeys {
	return [self.allKeys reject:^BOOL(id object) {
		if([[self valueForKey:object] count] == 0) {
			return YES;
		}
		
		return NO;
	}];
}

- (NSInteger)sectionsWithResults {
	return self.allowedKeys.count;
}

@end
