//
//  VenueRankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "VenueRankingTableViewCell.h"

@implementation VenueRankingTableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
    [super setPlayEvent:play];
    
	self.textLabel.text = play.venueName;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	NSString *showCountString = play.venueShowsCount == 1 ? @"show" : @"shows";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %ld %@\n%@",
								play.playCount, playString, (long)play.venueShowsCount, showCountString,
                                 play.location];
}

@end
