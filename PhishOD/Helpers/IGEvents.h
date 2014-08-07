//
//  IGEvents.h
//  PhishOD
//
//  Created by Alec Gorge on 8/7/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGEvent : NSObject

@property (nonatomic) NSString *eventName;
@property (nonatomic) NSDate *startDate;

- (instancetype)initWithEventName:(NSString *)eventName;

- (void)endTimedEventWithAttributes:(NSDictionary *)attributes
                         andMetrics:(NSDictionary *)metrics;

- (void)endTimedEvent;

@end

@interface IGEvents : NSObject

+ (void)setup;

+ (void)trackEvent:(NSString *)eventName
    withAttributes:(NSDictionary *)attributes
        andMetrics:(NSDictionary *)metrics;

+ (void)trackEvent:(NSString *)eventName;

+ (IGEvent *)startTimedEvent:(NSString *)eventName;

@end
