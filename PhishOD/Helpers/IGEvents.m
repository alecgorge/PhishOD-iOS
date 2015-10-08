//
//  IGEvents.m
//  PhishOD
//
//  Created by Alec Gorge on 8/7/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGEvents.h"

#import "IGThirdPartyKeys.h"

#import <Flurry-iOS-SDK/Flurry.h>
#import <Crashlytics/Crashlytics.h>

#if defined(DEBUG)
#define RETURN_IN_DEBUG() //return;
#else
#define RETURN_IN_DEBUG()
#endif

@implementation IGEvent

- (instancetype)initWithEventName:(NSString *)eventName {
	if(self = [super init]) {
		self.eventName = eventName;
		self.startDate = [NSDate date];
	}
	
	return self;
}

- (void)endTimedEventWithAttributes:(NSDictionary *)attributes
                         andMetrics:(NSDictionary *)metrics {
	NSMutableDictionary *d = metrics.mutableCopy;
    
    if(!d) {
        d = NSMutableDictionary.dictionary;
    }
    
	d[@"duration"] = @([NSDate.date timeIntervalSinceDate:self.startDate]);
    
	dbug(@"[EVENTS] Completed timed event '%@' with duration %f, attributes %@ and metrics: %@", self.eventName, [d[@"duration"] doubleValue], attributes, metrics);
    
	RETURN_IN_DEBUG();
    
    if ([self.eventName isEqualToString:@"share"]) {
        [Answers logShareWithMethod:attributes[@"activity_type"]
                        contentName:attributes[@"content"]
                        contentType:@"track"
                          contentId:attributes[@"content_id"]
                   customAttributes:d];
        
        return;
    }
    else if([self.eventName isEqualToString:@"signin"]) {
        [Answers logLoginWithMethod:attributes[@"method"]
                            success:attributes[@"success"]
                   customAttributes:d];
    }
    else if([self.eventName isEqualToString:@"played_track"]) {
        [Answers logContentViewWithName:[NSString stringWithFormat:@"%@ - %@ - %@", attributes[@"artist"], attributes[@"album"], attributes[@"title"]]
                            contentType:@"track"
                              contentId:attributes[@"id"]
                       customAttributes:attributes];
    }
    
    [Flurry endTimedEvent:self.eventName
           withParameters:attributes];
}

- (void)endTimedEvent {
	[self endTimedEventWithAttributes:nil
                           andMetrics:nil];
}

@end

@implementation IGEvents

+ (void)setup {
    RETURN_IN_DEBUG();
}

+ (void)trackEvent:(NSString *)eventName
    withAttributes:(NSDictionary *)attributes
        andMetrics:(NSDictionary *)metrics {
    dbug(@"[EVENTS] Logging event '%@' with attributes: %@, metrics: %@", eventName, attributes, metrics);
	
    RETURN_IN_DEBUG();
    
    if ([eventName isEqualToString:@"share"]) {
        [Answers logShareWithMethod:attributes[@"activity_type"]
                        contentName:attributes[@"content"]
                        contentType:@"track"
                          contentId:attributes[@"content_id"]
                   customAttributes:metrics];
        
        return;
    }
    else if([eventName isEqualToString:@"signin"]) {
        [Answers logLoginWithMethod:attributes[@"method"]
                            success:attributes[@"success"]
                   customAttributes:attributes];
    }
    else if([eventName isEqualToString:@"played_track"]) {
        [Answers logContentViewWithName:[NSString stringWithFormat:@"%@ - %@ - %@", attributes[@"artist"], attributes[@"album"], attributes[@"title"]]
                            contentType:@"track"
                              contentId:attributes[@"id"]
                       customAttributes:attributes];
    }
    
    [Answers logCustomEventWithName:eventName
                   customAttributes:attributes];
    
    [Flurry logEvent:eventName
      withParameters:attributes];
}

+ (void)trackEvent:(NSString *)eventName {
	[self trackEvent:eventName
      withAttributes:nil
          andMetrics:nil];
}

+ (IGEvent *)startTimedEvent:(NSString *)eventName {
	dbug(@"[EVENTS] Starting a timed event '%@'", eventName);

    [Flurry logEvent:eventName
               timed:YES];
    
	return [IGEvent.alloc initWithEventName:eventName];
}

@end
