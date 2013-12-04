//
//  YearRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearRankingTableViewCell.h"

@implementation YearRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = play.year;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
								play.playCount, playString];
}

@end
