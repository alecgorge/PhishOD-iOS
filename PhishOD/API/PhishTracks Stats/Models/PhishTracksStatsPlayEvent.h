//
//  PhishTracksStatsHistoryItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PHODCollection.h"

@interface PhishTracksStatsPlayEvent : NSObject<PHODCollection>

- (id)initWithDictionary:(NSDictionary *)playDict;

@property (readonly) NSString *streamingSite;

// track
@property (readonly) NSInteger trackId;
@property (readonly) NSString *trackSlug;
@property (readonly) NSString *trackTitle;
@property (readonly) NSInteger trackDuration;
@property (readonly) NSString *setName;

// show
@property (readonly) NSInteger showId;
@property (readonly) NSString *showDate;
@property (readonly) NSInteger showDuration;

// venue
@property (readonly) NSInteger venueId;
@property (readonly) NSString *venueName;
@property (readonly) NSString *venueSlug;
@property (readonly) NSInteger venueShowsCount;
@property (readonly) NSString *location;
@property (readonly) NSString *venuePastNames;
@property (readonly) NSDecimalNumber *venueLatitude;
@property (readonly) NSDecimalNumber *venueLongitude;

// tour
@property (readonly) NSInteger tourId;
@property (readonly) NSString *tourName;
@property (readonly) NSString *tourSlug;
@property (readonly) NSInteger tourShowsCount;
@property (readonly) NSString *tourStartsOn;
@property (readonly) NSString *tourEndsOn;

// year
@property (readonly) NSString *year;

@property (readonly) NSInteger userId;
@property (readonly) NSString *username;

@property (readonly) NSString *playCount;
@property (readonly) NSString *ranking;
@property (readonly) NSString *timeSincePlayed;

@end
