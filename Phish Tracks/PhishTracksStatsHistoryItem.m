//
//  PhishTracksStatsHistoryItem.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsHistoryItem.h"

@implementation PhishTracksStatsHistoryItem

- (id)initWithJSON:(NSDictionary *)json {
	if(self = [super init]) {
		_timeSincePlayed = json[@"time_since_played"];
		_title = json[@"title"];
		_showDate = json[@"show_info"][@"show_date"];
		_playCount = json[@"play_count"];
	}
	return self;
}

@end
