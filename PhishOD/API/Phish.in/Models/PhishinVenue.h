//
//  PhishinVenue.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishinVenue : NSObject<NSCoding>

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) int id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *past_names;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) int shows_count;
@property (nonatomic) NSString *location;
@property (nonatomic) NSString *slug;

@property (nonatomic) NSArray *show_dates;
@property (nonatomic) NSArray *show_ids;

@end
