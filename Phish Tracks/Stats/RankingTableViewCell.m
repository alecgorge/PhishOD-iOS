//
//  RankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RankingTableViewCell.h"
#import "StreamingMusicViewController.h"

@implementation RankingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_rankingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 20, 20)];  // origin.y==7 aligns with main cell label baseline.
		_rankingLabel.font = [_rankingLabel.font fontWithSize:14.0];               // the 1 gets overidden in layoutSubviews.
		_rankingLabel.textColor = [UIColor darkGrayColor];
//		_rankingLabel.backgroundColor = [UIColor redColor];
		_rankingLabel.numberOfLines = 1;
		[_rankingLabel sizeToFit];
		self.indentationWidth = 18.0;
		self.indentationLevel = 1;
		self.detailTextLabel.textColor = [UIColor darkGrayColor];
        self.detailTextLabel.numberOfLines = 2;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		[self.contentView addSubview:_rankingLabel];
    }
    return self;
}

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play
{
	self.rankingLabel.text = play.ranking;
	[self.rankingLabel sizeToFit];
	self.textLabel.text = play.trackTitle;
	NSString *playString = [play.playCount isEqualToString:@"1"] ? @"play" : @"plays";
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@ - %@\n%@ - %@",
								play.playCount, playString, play.showDate,
                                 [StreamingMusicViewController formatTime:play.trackDuration / 1000.0f],
                                 play.venueName, play.location];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGFloat lh = self.rankingLabel.frame.size.height;
	CGFloat ch = self.frame.size.height;
	CGRect oldFrame = self.rankingLabel.frame;
	self.rankingLabel.frame = CGRectMake(oldFrame.origin.x, (ch-lh)/2, oldFrame.size.width, oldFrame.size.height);
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//}

@end
