//
//  PhishinSong.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinSong.h"

@implementation PhishinSong

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict[@"alias_for"] isKindOfClass:[NSNull class]] ? [dict[@"id"] integerValue] : [dict[@"alias_for"] integerValue];
		self.title = dict[@"title"];
		self.tracks_count = [dict[@"tracks_count"] integerValue];
		self.slug = dict[@"slug"];
		
		self.tracks = @[];
		
		if(dict[@"tracks"]) {
			self.tracks = [dict[@"tracks"] map:^id(id object) {
				return [[PhishinTrack alloc] initWithDictionary:object
														 andShow:nil];
			}];
		}
    }
    return self;
}

- (NSString*)netSlug {
	NSString *lower = [self.title lowercaseString];
	NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789 "] invertedSet];
	lower = [[lower componentsSeparatedByCharactersInSet: set] componentsJoinedByString:@""];
	
	return [[lower componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@"-"];
}

@end
