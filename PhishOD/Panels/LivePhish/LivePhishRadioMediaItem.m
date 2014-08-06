//
//  LivePhishRadioMediaItem.m
//  PhishOD
//
//  Created by Alec Gorge on 8/4/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishRadioMediaItem.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <KVOController/FBKVOController.h>
#import <StreamingKit/STKHTTPDataSource.h>

#import "AppDelegate.h"
#import "NowPlayingBarViewController.h"
#import "AGMediaPlayerViewController.h"

@interface LivePhishRadioMediaItem ()

@property (nonatomic) FBKVOController *kvo;

@end

@implementation LivePhishRadioMediaItem

- (id)init {
    if (self = [super init]) {
        self.id = kLivePhishRadioMediaItemId;
        self.title = @"Waiting for metadata...";
        self.artist = @"Phish?";
        self.album = @"Live Phish Radio (powered by nugs.net)";
        
        self.duration = FLT_MIN;

        self.displayText = self.title;
        self.displaySubText = self.album;
        
        self.track = 1;
        
        self.kvo = [FBKVOController.alloc initWithObserver:self];
    }
    
    return self;
}

- (void)setDataSource:(STKDataSource *)dataSource {
    [self.kvo unobserve:self.dataSource];
    
    [super setDataSource:dataSource];
    
    [self.kvo observe:dataSource
              keyPath:@"shoutCastSongMetadata"
              options:NSKeyValueObservingOptionNew
               action:@selector(updateMetadata)];
}

- (void)updateMetadata {
    STKHTTPDataSource *http = (STKHTTPDataSource *)self.dataSource;
    
    NSDictionary *meta = http.shoutCastSongMetadata;
    
    if(!meta) {
        return;
    }
    
    NSString *title = meta[kSTKShoutcastSongMetadataTitleKey];
    
    NSArray *artistSplit = [title componentsSeparatedByString:@": \""];
    self.artist = [artistSplit[0] capitalizedString];
    
    title = artistSplit[1];
    NSArray *parts = [[title componentsSeparatedByString:@" - "] map:^id(NSString *object) {
        return [object stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }];
    
    NSString *song = parts[0];
    self.title = [[song substringWithRange:NSMakeRange(0, song.length - 1)] stringByAppendingString:@" — Live Phish Radio"];
    
    if(parts.count == 2) {
        self.album = [NSString stringWithFormat:@"%@ — %@", parts[1], self.artist];
    }
    else if(parts.count == 3) {
        self.album = [NSString stringWithFormat:@"%@ — %@ — %@", parts[1], parts[2], self.artist];
    }
    
    self.displayText = self.title;
    self.displaySubText = self.album;
    
    [AGMediaPlayerViewController.sharedInstance redrawUICompletely];
}

- (NSURL *)url {
    static NSURL *__url = nil;
    
    if (__url == nil) {
        __url = [NSURL URLWithString:@"http://radio.nugs.net:8002/"];
    }
    
    return __url;
}

- (NSString *)shareText {
    return [NSString stringWithFormat:@"#nowplaying %@ — %@ — %@ via @phishod", self.title, self.album, self.artist];
}

- (void)streamURL:(void (^)(NSURL *))callback {
    callback(self.url);
}

+ (void)playLivePhishRadio {
    if(!NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        [AppDelegate.sharedDelegate presentMusicPlayer];
    }
    
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:@[
                                                                        LivePhishRadioMediaItem.alloc.init
                                                                        ]
                                                           startIndex:0];
}

@end
