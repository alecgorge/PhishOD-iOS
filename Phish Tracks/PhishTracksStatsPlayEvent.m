//
//  PhishTracksStatsHistoryItem.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsPlayEvent.h"

@implementation PhishTracksStatsPlayEvent

- (id)initWithDictionary:(NSDictionary *)playDict
{
	if(self = [super init]) {
		if ([playDict hasKey:@"play_event"]) {
			playDict = [playDict objectForKey:@"play_event"];
		}

		_trackId = [playDict[@"track_id"] integerValue];
		_trackSlug = playDict[@"track_slug"];
		_trackTitle = playDict[@"track_title"];
		_trackDuration = [playDict[@"track_duration"] integerValue];
		_showId = [playDict[@"show_id"] integerValue];
		_showDate = playDict[@"show_date"];
		_location = playDict[@"location"];
		_streamingSite = playDict[@"streaming_site"];
		_venueName = playDict[@"venue_name"];

		NSDictionary *userDict = playDict[@"user"];
		if (userDict) {
			_userId = [userDict[@"id"] integerValue];
			_username = userDict[@"username"];
		}

		// dynamic play attributes
		_playCount = [NSString stringWithFormat:@"%@", playDict[@"play_count"]];
		_ranking = [NSString stringWithFormat:@"%@", playDict[@"ranking"]];
		_timeSincePlayed = playDict[@"time_since_played"];
	}
	return self;
}

@end
