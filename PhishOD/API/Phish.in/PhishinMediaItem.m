//
//  PhishinMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinMediaItem.h"

#import "PhishinDownloader.h"

@implementation PhishinMediaItem

- (instancetype)initWithTrack:(PhishinTrack*)track
					   inShow:(PhishinShow *)show {
	if (self = [super init]) {
		self.phishinTrack = track;
		self.phishinShow = show;
        
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

- (NSURL *)cachedStreamURL {
	return [PhishinDownloadOperation isTrackCached:self.phishinTrack
											inShow:self.phishinShow];
}

- (void)streamURL:(void (^)(NSURL *))callback {
	NSURL *file = self.cachedStreamURL;
	if(file) {
		callback(file);
	}
	else {
		callback(self.phishinTrack.mp3);
	}
}

- (BOOL)isCacheable {
	return self.phishinTrack.isCacheable;
}

- (BOOL)isCached {
	return self.phishinTrack.isCached;
}

- (PhishinDownloader *)downloader {
	return self.phishinTrack.downloader;
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
