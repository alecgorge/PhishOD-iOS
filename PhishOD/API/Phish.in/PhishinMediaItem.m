//
//  PhishinMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinMediaItem.h"

#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/SDWebImageManager.h>

#import "PhishinDownloader.h"

@interface PhishinMediaItem () {
    MPMediaItemArtwork *_artwork;
    BOOL _hasStartedFetching;
}

@end

@implementation PhishinMediaItem

- (instancetype)initWithTrack:(PhishinTrack*)track
					   inShow:(PhishinShow *)show {
	if (self = [super init]) {
		self.phishinTrack = track;
		self.phishinShow = show;
        
        self.title = track.title;
        
        if(track.show.venue) {
            self.album = [NSString stringWithFormat:@"%@ - %@ - %@", track.show.date, track.show.venue.name, track.show.venue.location, nil];
        }
        else {
            self.album = [NSString stringWithFormat:@"%@", track.show.date, nil];
        }

        self.artist = @"Phish";
        self.id = track.id;
        self.trackNumber = track.track;
        
        self.duration = track.duration;
        
        self.displayText = track.title;
        self.displaySubtext = self.album;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.phishinTrack = [aDecoder decodeObjectForKey:@"phishinTrack"];
        self.phishinShow = [aDecoder decodeObjectForKey:@"phishinShow"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.phishinTrack
                  forKey:@"phishinTrack"];
    
    [aCoder encodeObject:self.phishinShow
                  forKey:@"phishinShow"];
}

- (NSURL *)playbackURL {
    NSURL *file = self.cachedFile;
    if(file) {
        return file;
    }
    else {
        return self.phishinTrack.mp3;
    }
}

- (MPMediaItemArtwork *)albumArt {
    return self.phishinShow.albumArt;
}

- (MPMediaItemArtwork *)artwork {
    return self.phishinShow.albumArt;
}

- (NSInteger)track {
    return self.trackNumber;
}

- (BOOL)isCacheable {
	return self.phishinTrack.isCacheable;
}

- (BOOL)isCached {
	return self.phishinTrack.isCached;
}

- (PHODDownloader *)downloader {
	return self.phishinTrack.downloader;
}

- (PHODDownloadItem *)downloadItem {
    return self.phishinTrack.downloadItem;
}

- (NSURL *)cachedFile {
    return self.phishinTrack.cachedFile;
}

- (BOOL)isDownloadingOrQueued {
	return self.phishinTrack.isDownloadingOrQueued;
}

- (void)loadMetadata:(void (^)(id<AGAudioItem>))metadataCallback {
    metadataCallback(self);
}

- (void)shareText:(void (^)(NSString *))stringBuilt {
    stringBuilt([NSString stringWithFormat:@"#nowplaying %@ — %@ — %@ via @phishod", self.title, self.album, self.artist]);
}

- (void)shareURL:(void (^)(NSURL *))urlFound {
    urlFound([NSURL URLWithString:[self.phishinTrack shareURLWithPlayedTime:0]]);
}

- (void)shareURLWithTime:(NSTimeInterval)shareTime
                callback:(void (^)(NSURL *))urlFound {
    urlFound([NSURL URLWithString:[self.phishinTrack shareURLWithPlayedTime:shareTime]]);
}

@end
