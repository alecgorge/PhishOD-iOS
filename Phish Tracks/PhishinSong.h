//
//  PhishinSong.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishinTrack.h"

@interface PhishinSong : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) int id;
@property (nonatomic) NSString *title;
@property (nonatomic, assign) int tracks_count;
@property (nonatomic) NSString *slug;
@property (nonatomic) NSArray *tracks;

@property (nonatomic, readonly) NSString *netSlug;

@end
