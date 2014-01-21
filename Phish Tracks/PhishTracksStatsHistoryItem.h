//
//  PhishTracksStatsHistoryItem.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsHistoryItem : NSObject

- (id)initWithJSON:(NSDictionary *)json;

@property (readonly) NSString *showDate;
@property (readonly) NSString *title;

@property (readonly) NSNumber *playCount;

@property (readonly) NSString *timeSincePlayed;

@end
