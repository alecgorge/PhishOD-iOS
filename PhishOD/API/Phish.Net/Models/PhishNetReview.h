//
//  PhishNetReview.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishNetReview : NSObject<NSCoding>

@property NSString *commentId;
@property NSDate *timestamp;
@property NSString *review;
@property NSString *author;

-(id)initWithJSON:(NSDictionary *) dict;

@end
