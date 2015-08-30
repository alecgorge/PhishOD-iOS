//
//  HFPodDataManager.h
//  PhishOD
//
//  Created by Alec Gorge on 8/24/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface HFPodcast : JSONModel {
    NSDate *_date;
}

@property (nonatomic) NSString *episode;
@property (nonatomic) NSURL *link;
@property (nonatomic) NSString *blurb;
@property (nonatomic) NSString *showDate;
@property (nonatomic, readonly) NSDate *date;

@end

@interface HFPodDataManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) NSArray *podcasts;

- (HFPodcast *)podcastForShow:(PhishinShow *)show;

@end
