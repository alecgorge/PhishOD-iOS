//
//  SetStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SetStatsViewController.h"
#import "ShowViewController.h"
#import "SetRankingTableViewCell.h"

@interface SetStatsViewController ()

@end

@implementation SetStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[SetRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    return [[ShowViewController alloc] initWithShowDate:play.showDate];
}

@end
