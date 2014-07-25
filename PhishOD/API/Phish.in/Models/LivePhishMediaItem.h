//
//  LivePhishMediaItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGMediaItem.h"

@class LivePhishSong, LivePhishCompleteContainer;

@interface LivePhishMediaItem : AGMediaItem

- (instancetype)initWithSong:(LivePhishSong *)song
        andCompleteContainer:(LivePhishCompleteContainer *)cont;

@property (nonatomic) LivePhishSong *song;
@property (nonatomic) LivePhishCompleteContainer *completeContainer;

@end
