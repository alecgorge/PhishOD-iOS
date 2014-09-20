//
//  RankingTableViewCell.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RankingTableViewCell.h"

@implementation RankingTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
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
        self.detailTextLabel.numberOfLines = 0;
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
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGFloat labelHeight = self.rankingLabel.frame.size.height;
	CGFloat cellHeight = self.frame.size.height;
	CGRect oldFrame = self.rankingLabel.frame;
	self.rankingLabel.frame = CGRectMake(oldFrame.origin.x, (cellHeight-labelHeight)/2, oldFrame.size.width, oldFrame.size.height);
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//}

@end
