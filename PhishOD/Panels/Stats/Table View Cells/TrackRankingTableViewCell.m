//
//  TrackRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TrackRankingTableViewCell.h"

#import "IGDurationHelper.h"

@implementation TrackRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = play.trackTitle;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ - %@\n%@ - %@",
								play.playCount, playString, play.showDate,
                                 [IGDurationHelper formattedTimeWithInterval:play.trackDuration / 1000.0f],
                                 play.venueName, play.location];
}

@end
