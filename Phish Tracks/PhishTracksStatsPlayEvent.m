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
        
		_streamingSite = playDict[@"streaming_site"];

        // track
		_trackId = [playDict[@"track_id"] integerValue];
		_trackSlug = playDict[@"track_slug"];
		_trackTitle = playDict[@"track_title"];
		_trackDuration = [playDict[@"track_duration"] integerValue];
		_setName = playDict[@"set_name"];
        
        // show
		_showId = [playDict[@"show_id"] integerValue];
		_showDate = playDict[@"show_date"];
		_showDuration = [playDict[@"show_duration"] integerValue];
        
        // venue
		_venueId = [playDict[@"venue_id"] integerValue];
		_venueSlug = playDict[@"venue_slug"];
		_venueName = playDict[@"venue_name"];
		_venuePastNames = playDict[@"venue_past_names"];
		_location = playDict[@"location"];
		_venueShowsCount = [playDict[@"venue_shows_count"] integerValue];
        
        if (playDict[@"venue_latitude"] && playDict[@"venue_latitude"] != [NSNull null])
            _venueLatitude = [NSDecimalNumber decimalNumberWithString:playDict[@"venue_latitude"]];
        
        if (playDict[@"venue_latitude"] && playDict[@"venue_longitude"] != [NSNull null])
            _venueLongitude = [NSDecimalNumber decimalNumberWithString:playDict[@"venue_longitude"]];
        
        // tour
		_tourId = [playDict[@"tour_id"] integerValue];
		_tourSlug = playDict[@"tour_slug"];
		_tourName = playDict[@"tour_name"];
		_tourStartsOn = playDict[@"tour_starts_on"];
		_tourEndsOn = playDict[@"tour_ends_on"];
		_tourShowsCount = [playDict[@"tour_shows_count"] integerValue];
        
        _year = [NSString stringWithFormat:@"%@", playDict[@"year"]];

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
