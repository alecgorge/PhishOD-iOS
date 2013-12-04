//
//  YearStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearStatsViewController.h"
#import "YearRankingTableViewCell.h"
#import "YearViewController.h"

@interface YearStatsViewController ()

@end

@implementation YearStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[YearRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    PhishinYear *year = [[PhishinYear alloc] init];
    year.year = play.year;
    return [[YearViewController alloc] initWithYear:year];
}

@end
