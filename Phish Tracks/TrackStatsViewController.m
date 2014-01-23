//
//  GlobalStatsViewController.m
//  Phish Tracks
//
//  This controller assumes the stats query has n>0 scalar stats followed by a ranking stat
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStats.h"
#import "TrackStatsViewController.h"
#import "ShowViewController.h"
#import "TrackRankingTableViewCell.h"

@interface TrackStatsViewController ()

@end

@implementation TrackStatsViewController

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return [[TrackRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    ShowViewController * c = [[ShowViewController alloc] initWithShowDate:play.showDate];
    c.autoplayTrackId = play.trackId;
    c.autoplay = [PhishTracksStats sharedInstance].autoplayTracks;
    return c;
}

@end
