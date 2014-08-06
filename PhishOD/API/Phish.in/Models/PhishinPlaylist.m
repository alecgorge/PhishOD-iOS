//
//  PhishinPlaylist.m
//  PhishOD
//
//  Created by Alec Gorge on 8/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinPlaylist.h"

#import "PhishinTrack.h"

@implementation PhishinPlaylist

- (instancetype)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.slug = dict[@"slug"];
		self.name = dict[@"name"];
		
		self.duration = [dict[@"duration"] doubleValue] / 1000.0f;
        
        __block NSInteger i = 1;
		self.tracks = [dict[@"tracks"] map:^id(NSDictionary *o) {
			PhishinTrack *track = [PhishinTrack.alloc initWithDictionary:o
                                                                 andShow:nil];
            track.position = i++;
            return track;
		}];
	}
	return self;
}

- (NSURL *)shareURL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://phish.in/play/%@", self.slug]];
}

@end
