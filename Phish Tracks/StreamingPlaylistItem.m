 //
//  StreamingPlaylistItem.m
//  Listen to the Dead
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StreamingPlaylistItem.h"

@implementation StreamingPlaylistItem

- (NSURL *)shareURLWithPlayedTime:(NSTimeInterval)elapsed {
	NSAssert(NO, @"shareURLWithPlayedTime: not implemented in subclass");
	return nil;
}

@end
