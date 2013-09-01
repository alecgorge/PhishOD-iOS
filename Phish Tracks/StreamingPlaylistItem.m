 //
//  StreamingPlaylistItem.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StreamingPlaylistItem.h"

@interface StreamingPlaylistItem()

@property NSString *album;

@end

@implementation StreamingPlaylistItem

- (id)initWithSong:(PhishSong *)song fromShow:(PhishShow *)show {
	if (self = [super init]) {
		self.song = song;
		self.show = show;
	}
	return self;
}

- (NSString *)title {
	return self.song.title;
}

- (NSString *)subtitle {
	if(!self.album) {
		self.album = [self.show.showDate stringByAppendingFormat:@" - %@ - %@", self.show.location, self.show.city, nil];
	}
	
	return self.album;
}

- (NSTimeInterval)duration {
	return self.song.duration;
}

- (NSURL *)file {
	return self.song.fileURL;
}

- (NSString *)shareTitle {
	static NSString *sub = nil;
	if(sub == nil) {
		sub = [NSString stringWithFormat: @"#nowplaying %@ - %@ - Phish via @phishod", self.song.title, self.show.showDate, nil];
	}
	
	return sub;
}

- (NSURL *)shareURL {
	static NSURL *sub = nil;
	if(sub == nil) {
		sub = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.phishtracks.com/shows/%@/%@", self.show.showDate, self.song.slug, nil]];
	}
	
	return sub;
}

@end
