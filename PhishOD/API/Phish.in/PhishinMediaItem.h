//
//  PhishinMediaItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AGMediaItem.h"

#import "PhishinTrack.h"

#import <AGAudioPlayer/AGAudioItem.h>

@interface PhishinMediaItem : AGAudioItemBase<PHODGenericTrack>

- (instancetype)initWithTrack:(PhishinTrack*) track
					   inShow:(PhishinShow *) show;

@property (nonatomic) PhishinTrack *phishinTrack;
@property (nonatomic) PhishinShow *phishinShow;

@end
