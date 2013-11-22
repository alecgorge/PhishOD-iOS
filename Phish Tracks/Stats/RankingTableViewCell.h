//
//  RankingTableViewCell.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishTracksStatsPlayEvent.h"

@interface RankingTableViewCell : UITableViewCell

@property UILabel *rankingLabel;

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play;

@end