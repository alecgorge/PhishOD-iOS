//
//  VenueStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "VenueStatsViewController.h"
#import "VenueRankingTableViewCell.h"
#import "VenueViewController.h"

@interface VenueStatsViewController ()

@end

@implementation VenueStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[VenueRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    PhishinVenue *venue = [[PhishinVenue alloc] initWithDictionary:@{ @"id": [NSNumber numberWithInteger:play.venueId],
                                                                      @"name": play.venueName,
                                                                      @"past_names": play.venuePastNames,
                                                                      @"latitude": play.venueLatitude,
                                                                      @"longitude": play.venueLongitude,
                                                                      @"shows_count": [NSNumber numberWithInteger:play.venueShowsCount],
                                                                      @"slug": play.venueSlug,
                                                                      @"location": play.location }];
    return [[VenueViewController alloc] initWithVenue:venue];
}

@end
