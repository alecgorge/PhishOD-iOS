//
//  HFPodDataManager.m
//  PhishOD
//
//  Created by Alec Gorge on 8/24/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "HFPodDataManager.h"

#import <AFNetworking/AFNetworking.h>

static NSURL *hfPodDataUrl;
static NSDateFormatter *hfPodDateFormatter;

@implementation HFPodcast

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper.alloc initWithDictionary:@{
                                                     @"gsx$episode.$t": @"episode",
                                                     @"gsx$link.$t": @"link",
                                                     @"gsx$blurb.$t": @"blurb",
                                                     @"gsx$showdate.$t": @"showDate",
                                                     }];
}

- (NSDate *)date {
    if(!_date) {
        _date = [hfPodDateFormatter dateFromString:self.showDate];
    }
    return _date;
}

@end

@implementation HFPodDataManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedFoo;
    dispatch_once(&once, ^ {
        hfPodDataUrl = [NSURL URLWithString:@"https://spreadsheets.google.com/feeds/list/11GEyNtW9yGeQgvT8OoqPhft3XMuywThrfWMZlhI-N8k/1/public/values?alt=json"];
        hfPodDateFormatter = NSDateFormatter.alloc.init;
        hfPodDateFormatter.dateFormat = @"MM/dd/yyyy";
        sharedFoo = [self.alloc init];
    });
    return sharedFoo;
}

- (instancetype)init {
    if (self = [super init]) {
        self.podcasts = @[];
        [self preload];
    }
    return self;
}

- (void)preload {
    AFHTTPSessionManager *manager = AFHTTPSessionManager.manager;
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    [manager GET:[hfPodDataUrl absoluteString]
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSArray *entry = responseObject[@"feed"][@"entry"];
             
             self.podcasts = [entry map:^id(id object) {
                 NSError *err;
                 HFPodcast *pod = [HFPodcast.alloc initWithDictionary:object
                                                                error:&err];
                 
                 if(err) {
                     dbug(@"Error deserialzing podcast: %@ %@", object, err);
                     return nil;
                 }
                 
                 return pod;
             }];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             dbug(@"HF Pod loading error: %@", error);
             // do nothing. this is a value-added feature
         }];
}

- (HFPodcast *)podcastForShow:(PhishinShow *)show {
    if(!show) {
        return nil;
    }
    
    NSDateFormatter *f = NSDateFormatter.alloc.init;
    f.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [f dateFromString:show.date];
    
    if (!date) {
        return nil;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *dateComponents = [calendar components:comps
                                                   fromDate:date];
    NSDate *date1 = [calendar dateFromComponents:dateComponents];
    
    for (HFPodcast *podcast in self.podcasts) {
        NSDateComponents *podDateComponents = [calendar components:comps
                                                          fromDate:podcast.date];
        NSDate *date2 = [calendar dateFromComponents:podDateComponents];
        if ([date2 compare:date1] == NSOrderedSame) {
            return podcast;
        }
    }
    
    return nil;
}

@end
