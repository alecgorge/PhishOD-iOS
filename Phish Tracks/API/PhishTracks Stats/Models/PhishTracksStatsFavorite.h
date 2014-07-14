//
//  PhishTracksStatsFavorite.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kStatsFavoriteTrack,
	kStatsFavoriteShow,
	kStatsFavoriteVenue,
	kStatsFavoriteTour
} StatsFavoriteType;

@interface PhishTracksStatsFavorite : NSObject

// Meta
@property(readonly, nonatomic, assign) StatsFavoriteType favoriteType;
@property(readonly, nonatomic, copy) NSString *streamingSite;
@property(nonatomic, retain) id phishinObject;
@property(readonly, nonatomic, assign) NSNumber *favoriteId;

// User
//@property(readonly, nonatomic, assign) NSNumber * userId;
//@property(readonly, nonatomic, copy) NSString *username;

// Track
@property(readonly, nonatomic, assign) NSNumber *trackId;
@property(readonly, nonatomic, copy) NSString *trackSlug;
@property(readonly, nonatomic, copy) NSString *trackTitle;
@property(readonly, nonatomic, assign) NSNumber *trackDuration;
@property(readonly, nonatomic, assign) NSNumber *position;
@property(readonly, nonatomic, copy) NSString *set;
@property(readonly, nonatomic, copy) NSString *setName;

// Show
@property(readonly, nonatomic, assign) NSNumber *showId;
@property(readonly, nonatomic, copy) NSString *showDate;
@property(readonly, nonatomic, assign) NSNumber *showDuration;
@property(readonly, nonatomic, assign) NSNumber *remastered;
@property(readonly, nonatomic, assign) NSNumber *sbd;

// Tour
@property(readonly, nonatomic, assign) NSNumber *tourId;
@property(readonly, nonatomic, copy) NSString *tourSlug;
@property(readonly, nonatomic, copy) NSString *tourName;
@property(readonly, nonatomic, copy) NSString *tourStartsOn;
@property(readonly, nonatomic, copy) NSString *tourEndsOn;
@property(readonly, nonatomic, assign) NSNumber *tourShowsCount;

// Venue
@property(readonly, nonatomic, assign) NSNumber *venueId;
@property(readonly, nonatomic, copy) NSString *venueSlug;
@property(readonly, nonatomic, copy) NSString *venueName;
@property(readonly, nonatomic, copy) NSString *venuePastNames;
@property(readonly, nonatomic, assign) NSNumber *venueLatitude;
@property(readonly, nonatomic, assign) NSNumber *venueLongitude;
@property(readonly, nonatomic, copy) NSString *location;
@property(readonly, nonatomic, assign) NSNumber *venueShowsCount;

- (id)initWithPhishinEntity:(id)phishinObject;
- (id)initWithDictionary:(NSDictionary *)dict andType:(StatsFavoriteType)type;

//- (id)asPhishinEntity;
- (NSDictionary *)asDictionary;
- (NSString *)description;

@end
