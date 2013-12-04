//
//  TourStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TourStatsViewController.h"
#import "TourViewController.h"
#import "TourRankingTableViewCell.h"

@interface TourStatsViewController ()

@end

@implementation TourStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[TourRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    PhishinTour *tour = [[PhishinTour alloc] initWithDictionary:@{ @"id": [NSNumber numberWithInteger:play.tourId] }];
    return [[TourViewController alloc] initWithTour:tour];
}

@end
