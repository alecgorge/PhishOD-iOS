//
//  IGShow.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "IGShowReview.h"
#import "IGVenue.h"
#import "IGTrack.h"

@class IGVenue;

@protocol IGShow
@end

@interface IGShow : JSONModel<NSCoding>

@property (nonatomic, assign) NSInteger recordingCount;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *displayDate;

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, strong) NSString *archiveIdentifier;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger ArtistId;
@property (nonatomic, assign) BOOL isSoundboard;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger reviewsCount;
@property (nonatomic, assign) double averageRating;

@property (nonatomic, strong) NSString<Optional> *venueCity;
@property (nonatomic, strong) NSString<Optional> *venueName;
@property (nonatomic, strong) IGVenue<Optional> *venue;

@property (nonatomic, strong) NSString<Optional> *source;
@property (nonatomic, strong) NSString<Optional> *lineage;
@property (nonatomic, strong) NSString<Optional> *taper;
@property (nonatomic, strong) NSString<Optional> *showDescription;

@property (nonatomic, strong) NSArray<Optional, ConvertOnDemand, IGShowReview> *reviews;
@property (nonatomic, strong) NSNumber<Optional> *trackCount;

@property (nonatomic, strong) NSArray<Optional, IGTrack> *tracks;

- (IGShow *)cache;

+ (NSString *)cacheKeyForShowId:(NSInteger)id;
+ (IGShow *)loadShowFromCacheForShowId:(NSInteger)date;

@end
