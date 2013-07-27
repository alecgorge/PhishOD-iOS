//
//  StreamingPlaylistItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishSong.h"
#import "PhishShow.h"

@interface StreamingPlaylistItem : NSObject

@property PhishShow *show;
@property PhishSong *song;

- (id)initWithSong:(PhishSong*)song fromShow:(PhishShow*)show;

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;
@property (readonly) NSTimeInterval duration;
@property (readonly) NSURL *file;

@property (readonly) NSString *shareTitle;
@property (readonly) NSURL *shareURL;

@end
