//
//  PhishNetSetlist.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PhishNetReview.h"

@interface PhishNetSetlist : NSObject<NSCoding>

- (id)initWithJSON:(NSDictionary*)dict;

@property NSString *setlistNotes;
@property NSString *setlistHTML;
@property NSString *rating;
@property NSString *ratingCount;
@property NSString *showId;

@property NSArray *reviews;

@end
