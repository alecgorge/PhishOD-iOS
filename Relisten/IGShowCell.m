//
//  IGShowCell.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGShowCell.h"

#import "IGDurationHelper.h"

@interface IGShowCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sbdLabel;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingCountLabel;

@end

@implementation IGShowCell

- (void)awakeFromNib {
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
}

- (void)updateCellWithShow:(IGShow *)show {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.dateLabel.text = show.displayDate;
    self.sbdLabel.hidden = !show.isSoundboard;
    
    [self.ratingView sizeToFit];
    self.ratingView.value = show.averageRating;
    self.ratingView.userInteractionEnabled = NO;

    self.venueLabel.text = [NSString stringWithFormat:@"%@\n%@", show.venueName, show.venueCity];
    self.durationLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration];
    self.recordingCountLabel.text = [NSString stringWithFormat:@"%ld recordings", (long)show.recordingCount];    
}

+ (CGFloat)height {
    return 70.0f;
}

@end
