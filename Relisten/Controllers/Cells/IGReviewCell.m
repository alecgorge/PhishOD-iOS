//
//  IGReviewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "IGReviewCell.h"

#import <AXRatingView/AXRatingView.h>

@interface IGReviewCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelUsername;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelDate;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelReview;
@property (weak, nonatomic) IBOutlet AXRatingView *uiRatingView;

@end

@implementation IGReviewCell

- (void)updateCellWithReview:(IGShowReview *)review
                 inTableView:(UITableView *)tableView {
    self.uiLabelTitle.text = review.reviewtitle;
    self.uiLabelUsername.text = review.reviewer;
    self.uiLabelDate.text = review.reviewdate;
    self.uiLabelReview.text = review.reviewbody;
    
    self.uiRatingView.value = review.stars.floatValue;
    self.uiRatingView.userInteractionEnabled = NO;
}

@end
