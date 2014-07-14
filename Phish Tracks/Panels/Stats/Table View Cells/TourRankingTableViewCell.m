//
//  TourRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TourRankingTableViewCell.h"

@implementation TourRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = play.tourName;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	NSString *showCountString = play.venueShowsCount == 1 ? @"show" : @"shows";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %ld %@\n%@ to %@",
								play.playCount, playString, (long)play.tourShowsCount, showCountString,
                                 play.tourStartsOn, play.tourEndsOn];
}

@end
