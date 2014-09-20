//
//  PlayHistoryTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PlayHistoryTableViewCell.h"
#import "IGDurationHelper.h"

@implementation PlayHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.detailTextLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.numberOfLines = 0;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play showUsername:(BOOL)showUsername
{
    self.textLabel.text = play.trackTitle;
    
    if (play.username && showUsername == YES) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - %@ - %@ - %@\n%@ - %@",
                                    play.timeSincePlayed, play.showDate,
                                    [IGDurationHelper formattedTimeWithInterval:play.trackDuration / 1000.0f],
                                    play.username,
                                    play.venueName, play.location];
    }
    else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%@ ago - %@ - %@\n%@ - %@",
                                    play.timeSincePlayed, play.showDate,
                                    [IGDurationHelper formattedTimeWithInterval:play.trackDuration / 1000.0f],
                                    play.venueName, play.location];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
