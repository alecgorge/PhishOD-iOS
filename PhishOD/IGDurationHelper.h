//
//  IGDurationHelper.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGDurationHelper : NSObject

+ (NSString *)generalizeStringWithInterval:(NSTimeInterval)interval;
+ (NSString *)formattedTimeWithInterval:(NSTimeInterval)interval;

@end
