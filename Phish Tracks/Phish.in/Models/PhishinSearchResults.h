//
//  PhishinSearchResults.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhishinShow.h"
#import "PhishinSong.h"
#import "PhishinVenue.h"
#import "PhishinTour.h"

@interface PhishinSearchResults : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, readonly) NSArray *allKeys;
@property (nonatomic, readonly) NSArray *allowedKeys;
@property (nonatomic, readonly) NSInteger sectionsWithResults;

@property (nonatomic) NSArray *show;
@property (nonatomic) NSArray *other_shows;
@property (nonatomic) NSArray *songs;
@property (nonatomic) NSArray *venues;
@property (nonatomic) NSArray *tours;

@end
