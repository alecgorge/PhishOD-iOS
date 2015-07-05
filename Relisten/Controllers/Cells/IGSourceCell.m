//
//  IGSourceCell.m
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "IGSourceCell.h"

#import "IGDurationHelper.h"

@implementation IGSourceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellWithSource:(IGShow *)source {
    self.uiLabelDuration.text = [IGDurationHelper formattedTimeWithInterval:source.duration];
    self.uiLabelReviewCount.text = @(source.reviewsCount).stringValue;
    self.uiLabelTaper.text = source.taper && ![source.taper isEqualToString:@""] ? source.taper : @"Unknown";
    self.uiLabelSource.text = source.source && ![source.source isEqualToString:@""] ? source.source : @"Unknown";
    self.uiLabelLineage.text = source.lineage && ![source.lineage isEqualToString:@""] ? source.lineage : @"Unknown";
    
    [self.uiRatingView sizeToFit];
    self.uiRatingView.value = source.averageRating;
    self.uiRatingView.userInteractionEnabled = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

@end
