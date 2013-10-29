//
//  PhishinStreamingPlaylistItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "StreamingPlaylistItem.h"

#import "PhishinTrack.h"

@interface PhishinStreamingPlaylistItem : StreamingPlaylistItem

- (instancetype)initWithTrack:(PhishinTrack*) track;

@property (nonatomic) PhishinTrack *track;

@end
