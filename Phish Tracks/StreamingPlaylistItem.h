//
//  StreamingPlaylistItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamingPlaylistItem : NSObject

@property NSString *title;
@property NSString *subtitle;
@property NSTimeInterval duration;
@property NSURL *file;

@end
