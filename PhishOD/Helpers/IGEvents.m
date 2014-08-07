//
//  IGEvents.m
//  PhishOD
//
//  Created by Alec Gorge on 8/7/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGEvents.h"

#import "IGThirdPartyKeys.h"

#import <AmazonInsightsSDK/AmazonInsightsSDK.h>

#if defined(DEBUG)
#define RETURN_IN_DEBUG() return;
#else
#define RETURN_IN_DEBUG()
#endif

static id<AIEventClient> eventClient;

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
    
    id<AIEvent> e = [eventClient createEventWithEventType:self.eventName];
    
    if(attributes) {
        for (NSString *key in attributes.keyEnumerator) {
            [e addAttribute:attributes[key]
                     forKey:key];
        }
    }
    
    if(metrics) {
        for (NSString *key in attributes.keyEnumerator) {
            [e addMetric:metrics[key]
                  forKey:key];
        }
    }
    
    [eventClient recordEvent:e];

}

- (void)endTimedEvent {
	[self endTimedEventWithAttributes:nil
                           andMetrics:nil];
}

@end

@implementation IGEvents

+ (void)setup {
    RETURN_IN_DEBUG();
    
    id<AIInsightsOptions> options = [AIAmazonInsights optionsWithAllowEventCollection:YES
                                                                 withAllowWANDelivery:YES];
    
    id<AIInsightsCredentials> credentials = [AIAmazonInsights credentialsWithApplicationKey:IGThirdPartyKeys.sharedInstance.amazonInsightsPublicKey
                                                                             withPrivateKey:IGThirdPartyKeys.sharedInstance.amazonInsightsPrivateKey];
    
    AIAmazonInsights* insights = [AIAmazonInsights insightsWithCredentials:credentials
                                                               withOptions:options];
    
    eventClient = insights.eventClient;
}

+ (void)trackEvent:(NSString *)eventName
    withAttributes:(NSDictionary *)attributes
        andMetrics:(NSDictionary *)metrics {
    dbug(@"[EVENTS] Logging event '%@' with attributes: %@, metrics: %@", eventName, attributes, metrics);
	
    RETURN_IN_DEBUG();
    
    id<AIEvent> e = [eventClient createEventWithEventType:eventName];
    
    if(attributes) {
        for (NSString *key in attributes.keyEnumerator) {
            [e addAttribute:attributes[key]
                     forKey:key];
        }
    }
    
    if(metrics) {
        for (NSString *key in attributes.keyEnumerator) {
            [e addMetric:metrics[key]
                  forKey:key];
        }
    }
    
    [eventClient recordEvent:e];
}

+ (void)trackEvent:(NSString *)eventName {
	[self trackEvent:eventName
      withAttributes:nil
          andMetrics:nil];
}

+ (IGEvent *)startTimedEvent:(NSString *)eventName {
	dbug(@"[EVENTS] Starting a timed event '%@'", eventName);

	return [IGEvent.alloc initWithEventName:eventName];
}

@end
