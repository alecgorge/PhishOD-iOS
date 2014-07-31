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

@interface AGMediaItem : NSObject <PHODGenericTrack>

@property (nonatomic) NSInteger id;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic, assign) NSInteger track;
@property (nonatomic) UIImage *albumArt;

@property (nonatomic) MPMediaItemArtwork *artwork;

- (void)streamURL:(void(^)(NSURL *file))callback;

@property (nonatomic) NSString *displayText;
@property (nonatomic) NSString *displaySubText;

@property (nonatomic) NSString *shareText;
@property (nonatomic) NSURL *shareURL;

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds;

@property (nonatomic, assign) NSTimeInterval duration;

@end
