//
//  PlayHistoryTableViewCell.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishTracksStatsPlayEvent.h"

@interface PlayHistoryTableViewCell : UITableViewCell

- (void)setPlayEvent:(PhishTracksStatsPlayEvent *)play showUsername:(BOOL)showUsername;

@end
