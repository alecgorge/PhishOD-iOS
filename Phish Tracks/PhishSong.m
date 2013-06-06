//
//  PhishSong.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishSong.h"

@implementation PhishSong

@synthesize trackId;
@synthesize title;
@synthesize position;
@synthesize duration;
@synthesize fileURL;
@synthesize filePath;
@synthesize slug;
@synthesize isPlayable;

- (id)initWithDictionary:(NSDictionary *) dict {
	if(self = [super init]) {
		self.title = dict[@"title"];
		self.slug = dict[@"slug"];
		self.isPlayable = NO;

		if(dict[@"id"] != nil) {
			self.isPlayable = YES;
			self.trackId = [dict[@"id"] intValue];
			self.position = [dict[@"title"] intValue];
			self.duration = [dict[@"duration"] doubleValue] / 1000.0f;
			self.filePath = dict[@"file_url"];
			self.fileURL = [NSURL URLWithString:[PHISH_TRACKS_PATH stringByAppendingString:self.filePath]];
		}
		
		if(dict[@"show"] != nil) {
			self.showDate = dict[@"show"][@"show_date"];
			self.showLocation = dict[@"show"][@"location"];
		}	
	}
	return self;
}

@end
