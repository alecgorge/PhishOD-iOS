//
//  PhishinStreamingPlaylistItem.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinStreamingPlaylistItem.h"

@implementation PhishinStreamingPlaylistItem

- (instancetype)initWithTrack:(PhishinTrack*)track {
	if (self = [super init]) {
		self.track = track;
	}
	return self;
}

- (NSString *)title {
	return self.track.title;
}

- (NSString *)subtitle {
	return [NSString stringWithFormat:@"%@ - %@ - %@", self.track.show.date, self.track.show.venue.name, self.track.show.venue.location, nil];
}

- (NSTimeInterval)duration {
	return self.track.duration;
}

- (NSURL *)file {
	return self.track.mp3;
}

- (NSString *)artist {
	return @"Phish";
}

- (NSString *)shareTitle {
	static NSString *sub = nil;
	if(sub == nil) {
		sub = [NSString stringWithFormat: @"#nowplaying %@ - %@ - Phish via @phishod", self.title, self.subtitle, nil];
	}
	
	return sub;
}

- (NSURL *)shareURLWithPlayedTime:(NSTimeInterval)elapsed {
	return [NSURL URLWithString: [self.track shareURLWithPlayedTime:elapsed]];
}

@end
