//
//  IguanaMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/5/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "IguanaMediaItem.h"

@implementation IguanaMediaItem

- (instancetype)initWithTrack:(IGTrack*)track
                       inShow:(IGShow *)show {
    if (self = [super init]) {
        if(show == nil && track.show != nil) {
            show = track.show;
        }
        
        self.iguanaTrack = track;
        self.iguanaShow = show;
        
        self.title = track.title;
        
        if(track.show.venue) {
            self.album = [NSString stringWithFormat:@"%@ - %@ - %@", show.displayDate, show.venue.name, show.venue.city, nil];
        }
        else {
            self.album = [NSString stringWithFormat:@"%@", show.displayDate, nil];
        }
        
        self.artist = IGAPIClient.sharedInstance.artist.name;
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
        self.iguanaTrack = [aDecoder decodeObjectForKey:@"iguanaTrack"];
        self.iguanaShow = [aDecoder decodeObjectForKey:@"iguanaShow"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.iguanaTrack
                  forKey:@"iguanaTrack"];
    
    [aCoder encodeObject:self.iguanaShow
                  forKey:@"iguanaShow"];
}

- (NSURL *)playbackURL {
    NSURL *file = self.cachedFile;
    if(file) {
        return file;
    }
    else {
        return [NSURL URLWithString:self.iguanaTrack.file];
    }
}

- (MPMediaItemArtwork *)artwork {
    return nil;
}

- (NSInteger)track {
    return self.trackNumber;
}

- (BOOL)isCacheable {
    return self.iguanaTrack.isCacheable;
}

- (BOOL)isCached {
    return self.iguanaTrack.isCached;
}

- (PHODDownloader *)downloader {
    return self.iguanaTrack.downloader;
}

- (PHODDownloadItem *)downloadItem {
    return self.iguanaTrack.downloadItem;
}

- (NSURL *)cachedFile {
    return self.iguanaTrack.cachedFile;
}

- (BOOL)isDownloadingOrQueued {
    return self.iguanaTrack.isDownloadingOrQueued;
}

- (void)loadMetadata:(void (^)(id<AGAudioItem>))metadataCallback {
    metadataCallback(self);
}

- (void)shareText:(void (^)(NSString *))stringBuilt {
    stringBuilt([NSString stringWithFormat:@"#nowplaying %@ — %@ — %@ via @relistenapp", self.title, self.album, self.artist]);
}

- (void)shareURL:(void (^)(NSURL *))urlFound {
    urlFound([self.iguanaTrack shareURLWithPlayedTime:0]);
}

- (void)shareURLWithTime:(NSTimeInterval)shareTime
                callback:(void (^)(NSURL *))urlFound {
    urlFound([self.iguanaTrack shareURLWithPlayedTime:shareTime]);
}

@end
