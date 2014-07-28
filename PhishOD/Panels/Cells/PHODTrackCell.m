//
//  PHODTrackCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODTrackCell.h"

#import <NAKPlaybackIndicatorView/NAKPlaybackIndicatorView.h>

#import "IGDurationHelper.h"
#import "AGMediaPlayerViewController.h"

#import "PhishinTrack.h"

@interface PHODTrackCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiTrackTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackRunningTime;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackNumber;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *uiPlaybackIndicator;

@end

@implementation PHODTrackCell

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView {
    self.uiTrackNumber.text = @(track.track).stringValue;
    self.uiTrackTitle.text = track.title;
    self.uiTrackRunningTime.text = [IGDurationHelper formattedTimeWithInterval:track.duration];
	
    self.uiPlaybackIndicator.tintColor = COLOR_PHISH_GREEN;
    if(track.id == AGMediaPlayerViewController.sharedInstance.currentItem.id) {
        self.uiTrackNumber.hidden = YES;
        if(AGMediaPlayerViewController.sharedInstance.playing) {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
        }
        else {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePaused;
        }
    }
    else {
        self.uiTrackNumber.hidden = NO;
        self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStateStopped;
    }
}

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 49;
    CGFloat rightMargin = 66;
    
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin, MAXFLOAT);
    CGRect labelSize = [track.title boundingRectWithSize:constraintSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]}
                                                 context:nil];
    
    return MAX(tableView.rowHeight, labelSize.size.height + 24);
}

@end
