//
//  StreamingPlaylistItem.h
//  Listen to the Dead
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StreamingPlaylistItem : NSObject

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;
@property (readonly) NSString *artist;
@property (readonly) NSTimeInterval duration;
@property (readonly) NSURL *file;

@property (readonly) NSString *shareTitle;

- (NSURL*)shareURLWithPlayedTime:(NSTimeInterval)elapsed;

@end
