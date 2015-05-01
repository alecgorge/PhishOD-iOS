//
//  AGMediaItem.h
//  iguana
//
//  Created by Alec Gorge on 3/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PhishinSong.h"

@class STKDataSource;

@interface AGMediaItem : NSObject <PHODGenericTrack, NSCoding>

@property (nonatomic) NSInteger id;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic, assign) NSInteger track;
@property (nonatomic) UIImage *albumArt;

@property (nonatomic) MPMediaItemArtwork *artwork;

@property (nonatomic, readonly) NSURL *playbackURL;

- (void)streamURL:(void(^)(NSURL *file))callback;

@property (nonatomic) NSString *displayText;
@property (nonatomic) NSString *displaySubText;

@property (nonatomic) NSString *shareText;
@property (nonatomic) NSURL *shareURL;

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic) STKDataSource *dataSource;

@end
