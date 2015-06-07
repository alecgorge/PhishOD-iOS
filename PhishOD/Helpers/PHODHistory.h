//
//  PHODHistory.h
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHODHistory : NSObject<NSCoding>

+ (instancetype)sharedInstance;

- (BOOL)addShow:(PhishinShow *)show;

@property (nonatomic) NSMutableOrderedSet *history;

@end
