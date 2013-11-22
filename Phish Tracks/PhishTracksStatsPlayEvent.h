//
//  PhishTracksStatsHistoryItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsPlayEvent : NSObject

- (id)initWithDict:(NSDictionary *)playDict;

@property (readonly) NSInteger trackId;
@property (readonly) NSString *trackSlug;
@property (readonly) NSString *trackTitle;
@property (readonly) NSString *trackDuration;
@property (readonly) NSInteger showId;
@property (readonly) NSString *showDate;
@property (readonly) NSString *location;
@property (readonly) NSString *streamingSite;
@property (readonly) NSString *venueName;

@property (readonly) NSInteger userId;
@property (readonly) NSString *username;

@property (readonly) NSString *playCount;
@property (readonly) NSString *ranking;
@property (readonly) NSString *timeSincePlayed;

@end
