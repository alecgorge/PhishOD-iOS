//
//  PhishNetTopShow.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PHODCollection.h"

@interface PhishNetTopShow : NSObject<PHODCollection>

@property NSString *showDate;
@property NSString *rating;
@property NSString *ratingCount;

@end
