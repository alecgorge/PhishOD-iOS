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
@property (weak, nonatomic) IBOutlet UILabel *reviewCount;

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

    NSString *venueName = show.venueName ? show.venueName : show.venue.name;
    NSString *venueCity = show.venueCity ? show.venueCity : show.venue.city;
    
    NSString *recordingCount = show.recordingCount > 0 ? [NSString stringWithFormat:@"%ld recordings", (long)show.recordingCount] : @"";
    
    self.venueLabel.text = [NSString stringWithFormat:@"%@\n%@", venueName, venueCity];
    self.durationLabel.text = [NSString stringWithFormat:@"%@\n%@", [IGDurationHelper formattedTimeWithInterval:show.duration], recordingCount];
    
    self.reviewCount.text = @(show.reviewsCount).stringValue;
}

+ (CGFloat)height {
    return 70.0f;
}

@end
