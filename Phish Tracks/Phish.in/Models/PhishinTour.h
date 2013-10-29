//
//  PhishinTour.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhishinShow.h"

@interface PhishinTour : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) int id;
@property (nonatomic) NSString *name;
@property (nonatomic, assign) int shows_count;
@property (nonatomic) NSString *starts_on;
@property (nonatomic) NSString *ends_on;
@property (nonatomic) NSString *slug;

@property (nonatomic) NSArray *shows;

@property (nonatomic, readonly) NSString *prettyDuration;

@end
