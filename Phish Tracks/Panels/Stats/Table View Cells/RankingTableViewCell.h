//
//  RankingTableViewCell.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishTracksStatsPlayEvent.h"
#import "StreamingMusicViewController.h"

@interface RankingTableViewCell : UITableViewCell

@property UILabel *rankingLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play;

@end
