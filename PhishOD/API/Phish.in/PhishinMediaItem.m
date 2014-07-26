//
//  PhishinMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinMediaItem.h"

@implementation PhishinMediaItem

- (instancetype)initWithTrack:(PhishinTrack*)track {
	if (self = [super init]) {
		self.phishinTrack = track;
        
        self.title = track.title;
        self.album = [NSString stringWithFormat:@"%@ - %@ - %@", track.show.date, track.show.venue.name, track.show.venue.location, nil];
        self.artist = @"Phish";
        self.id = track.id;
        self.track = track.track;
        
        self.duration = track.duration;
        
        self.displayText = track.title;
        self.displaySubText = self.album;
	}
	return self;
}

- (void)streamURL:(void (^)(NSURL *))callback {
    callback(self.phishinTrack.mp3);
}

- (NSURL *)shareURL {
    return [NSURL URLWithString:[self.phishinTrack shareURLWithPlayedTime:0]];
}

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds {
    return [NSURL URLWithString:[self.phishinTrack shareURLWithPlayedTime:seconds]];
}

- (NSString *)shareText {
    return [NSString stringWithFormat:@"#nowplaying %@ — %@ — %@ via @phishod", self.title, self.album, self.artist];
}

@end
