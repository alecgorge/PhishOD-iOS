//
//  PlayHistoryTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PlayHistoryTableViewCell.h"

@implementation PlayHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.detailTextLabel.textColor = [UIColor darkGrayColor];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
	self.textLabel.text = play.trackTitle;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - %@ - %@ - %@",
								play.timeSincePlayed, play.showDate, play.venueName, play.location];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
