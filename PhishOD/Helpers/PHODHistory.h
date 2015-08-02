//
//  PHODHistory.h
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IGShow;

@interface PHODHistory : NSObject<NSCoding>

+ (instancetype)sharedInstance;

#ifdef IS_PHISH
- (BOOL)addShow:(PhishinShow *)show;
#else
- (BOOL)addShow:(IGShow *)show;
#endif

@property (nonatomic) NSMutableOrderedSet *history;

@end
