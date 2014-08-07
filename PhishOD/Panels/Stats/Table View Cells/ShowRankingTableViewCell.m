//
//  ShowRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "IGDurationHelper.h"

#import "ShowRankingTableViewCell.h"

@implementation ShowRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = play.showDate;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@\n%@ - %@",
								play.playCount, playString,
                                 [IGDurationHelper formattedTimeWithInterval:play.showDuration / 1000.0f],
                                 play.venueName, play.location];
}

@end
