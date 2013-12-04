//
//  ShowStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ShowStatsViewController.h"
#import "ShowViewController.h"
#import "ShowRankingTableViewCell.h"

@interface ShowStatsViewController ()

@end

@implementation ShowStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[ShowRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    return [[ShowViewController alloc] initWithShowDate:play.showDate];
}

@end
