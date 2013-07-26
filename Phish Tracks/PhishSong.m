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
			
			if([dict[@"show"][@"location"] rangeOfString:@" - "].location == NSNotFound) {
				self.showLocation = [dict[@"show"][@"location"] stringByReplacingOccurrencesOfString:@", "
																				 withString:@"\n"];
			}
			else {
				self.showLocation = [dict[@"show"][@"location"] stringByReplacingOccurrencesOfString:@" - "
																						  withString:@"\n"];
			}
		}
	}
	return self;
}

- (void)setShowDate:(NSString *)showDate {
	_showDate = showDate;
	
	self.index = [self.showDate substringWithRange:NSMakeRange(2, 2)];
}

- (NSString*)netSlug {
	NSString *lower = [self.title lowercaseString];
	NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789 "] invertedSet];
	lower = [[lower componentsSeparatedByCharactersInSet: set] componentsJoinedByString:@""];
	
	return [[lower componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@"-"];
}

@end
