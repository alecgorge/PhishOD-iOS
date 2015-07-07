//
//  IguanaMediaItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/5/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "AGAudioItem.h"

#import "IGAPIClient.h"

@interface IguanaMediaItem : AGAudioItemBase

- (instancetype)initWithTrack:(IGTrack*) track
                       inShow:(IGShow *) show;

@property (nonatomic) IGTrack *iguanaTrack;
@property (nonatomic) IGShow *iguanaShow;

@end
