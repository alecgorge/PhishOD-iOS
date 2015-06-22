//
//  IGYearCell.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGYearCell.h"

#import "IGDurationHelper.h"

@interface IGYearCell ()

@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *showAndRecordingLabel;

@end

@implementation IGYearCell

- (void)setup {
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
}

- (void)updateCellWithYear:(IGYear *)year {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.yearLabel.text = @(year.year).stringValue;
    self.durationLabel.text = [IGDurationHelper generalizeStringWithInterval:year.duration];
    self.showAndRecordingLabel.text = [NSString stringWithFormat:@"%lu shows, %lu recordings", (unsigned long)year.showCount, (unsigned long)year.recordingCount];
    
    [self.ratingView sizeToFit];
    self.ratingView.value = year.avgRating;
    self.ratingView.userInteractionEnabled = NO;
}

+ (CGFloat)height {
    return 56.0f;
}

@end
