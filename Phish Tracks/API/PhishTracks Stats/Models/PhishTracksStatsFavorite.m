//
//  PhishTracksStatsFavorite.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsFavorite.h"

@implementation PhishTracksStatsFavorite {
	NSMutableDictionary *fields;
	StatsFavoriteType _favoriteType;
}

- (id)initWithPhishinEntity:(id)phishinObject
{
	self =  [self init];
    if (self) {
        fields = [NSMutableDictionary dictionary];
        [fields setObject:@"phishin" forKey:@"streaming_site"];
        
        if ([phishinObject isKindOfClass:[PhishinTrack class]]) {
            _favoriteType = kStatsFavoriteTrack;
            PhishinTrack *track = phishinObject;
            [self setPhishinTrackFields:track];
            [self setPhishinShowFields:track.show];
//            [self setPhishinTourFields:track.show.tour];
            [fields setObject:[NSNumber numberWithInteger:track.show.tour_id] forKey:@"tour_id"];
            [self setPhishinVenueFields:track.show.venue];
        }
        else if ([phishinObject isKindOfClass:[PhishinShow class]]) {
            _favoriteType = kStatsFavoriteShow;
            PhishinShow *show = phishinObject;
            [self setPhishinShowFields:show];
            [fields setObject:[NSNumber numberWithInteger:show.tour_id] forKey:@"tour_id"];
            [self setPhishinVenueFields:show.venue];
        }
        else if ([phishinObject isKindOfClass:[PhishinTour class]]) {
            _favoriteType = kStatsFavoriteTour;
            PhishinTour *tour = phishinObject;
            [self setPhishinTourFields:tour];
        }
        else if ([phishinObject isKindOfClass:[PhishinVenue class]]) {
            _favoriteType = kStatsFavoriteVenue;
            PhishinVenue *venue = phishinObject;
            [self setPhishinVenueFields:venue];
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict andType:(StatsFavoriteType)type
{
	if (self = [super init]) {
		fields = [dict mutableCopy];
		_favoriteType = type;
	}

	return self;
}

#pragma mark -
#pragma mark Phishin Entity Helpers

- (void)setPhishinTrackFields:(PhishinTrack *)track
{
    [fields setObject:[NSNumber numberWithInteger:track.id] forKey:@"track_id"];
    [fields setObject:track.slug forKey:@"track_slug"];
    [fields setObject:track.title forKey:@"track_title"];
    [fields setObject:[NSNumber numberWithInteger:track.duration] forKey:@"track_duration"];
    [fields setObject:track.set forKey:@"set"];
    [fields setObject:[NSNumber numberWithInteger:track.position] forKey:@"position"];
}

- (void)setPhishinShowFields:(PhishinShow *)show
{
    [fields setObject:[NSNumber numberWithInteger:show.id] forKey:@"show_id"];
    [fields setObject:show.date forKey:@"show_date"];
    [fields setObject:[NSNumber numberWithInteger:show.duration] forKey:@"show_duration"];
    [fields setObject:[NSNumber numberWithBool:show.sbd] forKey:@"sbd"];
    [fields setObject:[NSNumber numberWithBool:show.remastered] forKey:@"remastered"];
}

- (void)setPhishinTourFields:(PhishinTour *)tour
{
    [fields setObject:[NSNumber numberWithInteger:tour.id] forKey:@"tour_id"];
    [fields setObject:tour.slug forKey:@"tour_slug"];
    [fields setObject:tour.name forKey:@"tour_name"];
    [fields setObject:tour.starts_on forKey:@"tour_starts_on"];
    [fields setObject:tour.ends_on forKey:@"tour_ends_on"];
    [fields setObject:[NSNumber numberWithInteger:tour.shows_count] forKey:@"tour_shows_count"];
}

- (void)setPhishinVenueFields:(PhishinVenue *)venue
{
    [fields setObject:[NSNumber numberWithInteger:venue.id] forKey:@"venue_id"];
    [fields setObject:venue.slug forKey:@"venue_slug"];
    [fields setObject:venue.name forKey:@"venue_name"];
    [fields setObject:venue.past_names forKey:@"venue_past_names"];
    [fields setObject:[NSNumber numberWithFloat:venue.latitude] forKey:@"venue_latitude"];
    [fields setObject:[NSNumber numberWithFloat:venue.longitude] forKey:@"venue_longitude"];
    [fields setObject:[NSNumber numberWithInteger:venue.shows_count] forKey:@"venue_shows_count"];
    [fields setObject:venue.location forKey:@"location"];
}

#pragma mark -
#pragma mark Common

- (NSString *)favoriteId { return fields[@"id"]; }
- (NSString *)streamingSite { return fields[@"streaming_site"]; }

#pragma mark Show

- (NSNumber *)showId { return fields[@"show_id"]; }
- (NSString *)showDate { return fields[@"show_date"]; }
- (NSNumber *)showDuration { return fields[@"show_duration"]; }
- (NSNumber *)remastered { return fields[@"remastered"]; }
- (NSNumber *)sbd { return fields[@"sbd"]; }

#pragma mark Tour

- (NSNumber *)tourId { return fields[@"tour_id"]; }
- (NSString *)tourSlug { return fields[@"tour_slug"]; }
- (NSString *)tourName { return fields[@"tour_name"]; }
- (NSString *)tourStartsOn { return fields[@"tour_starts_on"]; }
- (NSString *)tourEndsOn { return fields[@"tour_ends_on"]; }
- (NSNumber *)tourShowsCount { return fields[@"tour_shows_count"]; }

#pragma mark Track

- (NSNumber *)trackId { return fields[@"track_id"]; }
- (NSString *)trackSlug { return fields[@"track_slug"]; }
- (NSString *)trackTitle { return fields[@"track_title"]; }
- (NSNumber *)trackDuration { return fields[@"track_duration"]; }
- (NSString *)set { return fields[@"set"]; }
- (NSString *)setName { return fields[@"set_name"]; }
- (NSNumber *)position { return fields[@"position"]; }

#pragma mark Venue

- (NSNumber *)venueId { return fields[@"venue_id"]; }
- (NSString *)venueSlug { return fields[@"venue_slug"]; }
- (NSString *)venueName { return fields[@"venue_name"]; }
- (NSString *)venuePastNames { return fields[@"venue_past_names"]; }
- (NSNumber *)venueLatitude { return fields[@"venue_latitude"]; }
- (NSNumber *)venueLongitude { return fields[@"venue_longitude"]; }
- (NSNumber *)venueShowsCount { return fields[@"venue_shows_count"]; }
- (NSString *)location { return fields[@"location"]; }

//- (id)asPhishinEntity
//{
//    if (_favoriteType == kStatsFavoriteTrack) {
//    }
//    else if (_favoriteType == kStatsFavoriteShow) {
//    }
//    else if (_favoriteType == kStatsFavoriteTour) {
//        return [[PhishinTour alloc] initWithDictionary:@{ @"id": self.tourId,
//                                                          @"": }];
//    }
//    else if (_favoriteType == kStatsFavoriteVenue) {
//    }
//    else {
//        [NSException raise:@"Invalid StatsFavoriteType" format:@"invalid_type=%d", _favoriteType];
//    }
//}

- (NSDictionary *)asDictionary
{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:30];
//    [dict setObject:@"phishin" forKey:@"streaming_site"];
//    
//    if (self.favoriteId)
//        [dict setObject:self.favoriteId forKey:@"id"];
//
    NSString *rootNodeName;
    
    if (_favoriteType == kStatsFavoriteTrack) {
        rootNodeName = @"favorite_track";
    }
    else if (_favoriteType == kStatsFavoriteShow) {
        rootNodeName = @"favorite_show";
    }
    else if (_favoriteType == kStatsFavoriteTour) {
        rootNodeName = @"favorite_tour";
    }
    else if (_favoriteType == kStatsFavoriteVenue) {
        rootNodeName = @"favorite_venue";
    }
    
    return @{ rootNodeName: [fields copy] };
}

- (NSString *)description
{
	NSString *typeName = nil;
	switch (_favoriteType) {
		case kStatsFavoriteTrack:
			typeName = @"kStatsFavoriteTrack";
			break;

		case kStatsFavoriteShow:
			typeName = @"kStatsFavoriteShow";
			break;

		case kStatsFavoriteTour:
			typeName = @"kStatsFavoriteTour";
			break;

		case kStatsFavoriteVenue:
			typeName = @"kStatsFavoriteVenue";
			break;
	}

	return [NSString stringWithFormat:@"PhishTracksStatFavorite:\n"
									   "  id   = %@\n"
									   "  type = %@\n"
									   "  streamingSite = %@\n"
									   "  trackId       = %@\n"
									   "  trackTitle    = %@\n"
									   "  showId        = %@\n"
									   "  showDate      = %@\n"
									   "  venueId       = %@\n"
									   "  venueName     = %@\n"
									   "  tourId        = %@\n"
									   "  tourName      = %@\n"
									   "  fieldsDict    = { ... }",
			self.favoriteId, typeName, self.streamingSite, self.trackId, self.trackTitle,
			self.showId, self.showDate, self.venueId, self.venueName, self.tourId, self.tourName];
}

@end
