//
//  SetRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SetRankingTableViewCell.h"

@implementation SetRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = [NSString stringWithFormat:@"%@, %@", play.showDate, play.setName];
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ - %@",
								play.playCount, playString,
                                 play.venueName, play.location];
}

@end
