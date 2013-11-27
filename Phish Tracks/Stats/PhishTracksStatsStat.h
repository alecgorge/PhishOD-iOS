//
//  PhishTracksStatsStat.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsStat : NSObject

@property NSString *name;
@property NSString *prettyName;
@property id value;
@property BOOL isScalar;

- (id)initWithDictionary:(NSDictionary *)dict;

- (NSInteger)count;

- (NSString *)valueAsString;

@end
