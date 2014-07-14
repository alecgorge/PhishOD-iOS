//
//  PhishSet.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishSet : NSObject

@property NSString *title;
@property NSArray *tracks;

- (id)initWithDictionary:(NSDictionary *) dict;

@end
