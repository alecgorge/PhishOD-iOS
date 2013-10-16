//
//  PhishinShow.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishinVenue.h"
#import "PhishinTrack.h"
#import "PhishinSet.h"

@interface PhishinShow : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) int id;
@property (nonatomic) NSString *date;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL incomplete;
@property (nonatomic, assign) BOOL missing;
@property (nonatomic, assign) BOOL sbd;
@property (nonatomic, assign) BOOL remastered;
@property (nonatomic, assign) int tour_id;
@property (nonatomic, assign) int venue_id;
@property (nonatomic, assign) int likes_count;

@property (nonatomic) NSString *venue_name;
@property (nonatomic) NSString *location;
@property (nonatomic) NSArray *tags;
@property (nonatomic) PhishinVenue *venue;

@property (nonatomic) NSArray *sets;
@property (nonatomic) NSArray *tracks;

@end
