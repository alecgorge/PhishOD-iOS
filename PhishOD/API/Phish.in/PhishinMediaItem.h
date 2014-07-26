//
//  PhishinMediaItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGMediaItem.h"

#import "PhishinTrack.h"

@interface PhishinMediaItem : AGMediaItem

- (instancetype)initWithTrack:(PhishinTrack*) track;

@property (nonatomic) PhishinTrack *phishinTrack;

@end
