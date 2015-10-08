//
//  PhishTracksStatsHistoryItem.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsPlayEvent.h"

#import <MediaPlayer/MediaPlayer.h>

@interface PhishTracksStatsPlayEvent () {
    MPMediaItemArtwork *_artwork;
    BOOL _artworkRequested;
}

@end

@implementation PhishTracksStatsPlayEvent

- (id)initWithDictionary:(NSDictionary *)playDict
{
	if(self = [super init]) {
		if ([playDict hasKey:@"play_event"]) {
			playDict = [playDict objectForKey:@"play_event"];
		}
        
		_streamingSite = playDict[@"streaming_site"];

        // track
		_trackId = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"track_id"]];
		_trackSlug = playDict[@"track_slug"];
		_trackTitle = playDict[@"track_title"];
		_trackDuration = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"track_duration"]];
		_setName = playDict[@"set_name"];
        
        // show
		_showId = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"show_id"]];
		_showDate = playDict[@"show_date"];
        _showDuration = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"show_duration"]];
        
        // venue
		_venueId = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"venue_id"]];
		_venueSlug = playDict[@"venue_slug"];
		_venueName = playDict[@"venue_name"];
		_venuePastNames = playDict[@"venue_past_names"];
		_location = playDict[@"location"];
		_venueShowsCount = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"venue_shows_count"]];
        
        if (playDict[@"venue_latitude"] && playDict[@"venue_latitude"] != [NSNull null])
            _venueLatitude = [NSDecimalNumber decimalNumberWithString:playDict[@"venue_latitude"]];
        
        if (playDict[@"venue_latitude"] && playDict[@"venue_longitude"] != [NSNull null])
            _venueLongitude = [NSDecimalNumber decimalNumberWithString:playDict[@"venue_longitude"]];
        
        // tour
		_tourId = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"tour_id"]];
		_tourSlug = playDict[@"tour_slug"];
		_tourName = playDict[@"tour_name"];
		_tourStartsOn = playDict[@"tour_starts_on"];
		_tourEndsOn = playDict[@"tour_ends_on"];
		_tourShowsCount = [PhishTracksStatsPlayEvent convertToInteger:playDict[@"tour_shows_count"]];
        
        _year = [NSString stringWithFormat:@"%@", playDict[@"year"]];

		NSDictionary *userDict = playDict[@"user"];
		if (userDict) {
			_userId = [PhishTracksStatsPlayEvent convertToInteger:userDict[@"id"]];
			_username = userDict[@"username"];
		}

		// dynamic play attributes
		_playCount = [NSString stringWithFormat:@"%@", playDict[@"play_count"]];
		_ranking = [NSString stringWithFormat:@"%@", playDict[@"ranking"]];
		_timeSincePlayed = playDict[@"time_since_played"];
	}
	return self;
}

- (MPMediaItemArtwork *)albumArt {
    if(_artwork == nil && _artworkRequested == NO) {
        PhishAlbumArtCache *c = PhishAlbumArtCache.sharedInstance;
        
        [c.sharedCache retrieveImageForEntity:self
                               withFormatName:PHODImageFormatFull
                              completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                  _artwork = [MPMediaItemArtwork.alloc initWithImage:image];
                              }];
    }
    
    return _artwork;
}

- (NSString *)displayText {
	return [NSString stringWithFormat:@"#%@ %@", self.ranking, self.showDate];
}

- (NSString *)displaySubtext {
	return self.location;
}

+ (NSInteger)convertToInteger:(id)object {
    if (object && object != [NSNull null]) {
        return [object integerValue];
    }
    else
        return 0;
}

#pragma mark - PHODCollection, FICEntity

- (NSString *)UUID {
    return self.showDate;
}

- (NSString *)sourceImageUUID {
    return self.showDate;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"phod://shatter"];
    
    NSDictionary *queryDictionary = @{@"date": self.showDate,
                                      @"venue": self.venueName,
                                      @"location": self.location };
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in queryDictionary) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
    }
    
    components.queryItems = queryItems;
    
    return components.URL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image
                                    withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        
        UIGraphicsPushContext(context);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}


@end
