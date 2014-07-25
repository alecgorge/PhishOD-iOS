//
//  LivePhishMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishMediaItem.h"

#import "LivePhishAPI.h"

@implementation LivePhishMediaItem

- (instancetype)initWithSong:(LivePhishSong *)song
        andCompleteContainer:(LivePhishCompleteContainer *)cont {
    if (self = [super init]) {
        self.song = song;
        self.completeContainer = cont;
        
        self.title = song.title;
        self.album = cont.displayTextWithDate;
        self.artist = cont.artist;
        self.id = song.id;
        self.track = song.track;
        
        self.duration = song.duration;
        
        self.displayText = song.title;
        self.displaySubText = cont.displayTextWithDate;
    }
    
    return self;
}

- (void)streamURL:(void (^)(NSURL *))callback {
    [LivePhishAPI.sharedInstance streamURLForSong:self.song
                            withCompleteContainer:self.completeContainer
                                          success:^(NSURL *streamURL) {
                                              callback(streamURL);
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              dbug(@"oh crap: %@ %@", operation, error);
                                          }];
}

- (NSURL *)shareURL {
    return self.completeContainer.livePhishPageURL;
}

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds {
    return self.completeContainer.livePhishPageURL;
}

- (NSString *)shareText {
    return [NSString stringWithFormat:@"#nowplaying %@ — %@ via @phishod", self.title, self.album];
}

@end
