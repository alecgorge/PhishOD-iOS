//
//  PhishSet.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishSet.h"
#import "PhishSong.h"

@implementation PhishSet

@synthesize title;
@synthesize tracks;

- (id)initWithDictionary:(NSDictionary *) dict {
	if(self = [super init]) {
		self.title = dict[@"title"];
		
		NSMutableArray *t = [NSMutableArray array];
		for (NSDictionary *d in dict[@"tracks"]) {
			[t addObject:[[PhishSong alloc] initWithDictionary:d]];
		}
		
		self.tracks = t;
	}
	return self;
}

@end
