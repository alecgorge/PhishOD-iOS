//
//  IGSourceCell.h
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGAPIClient.h"

#import <AXRatingView/AXRatingView.h>

@interface IGSourceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *uiLabelDuration;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelReviewCount;
@property (weak, nonatomic) IBOutlet AXRatingView *uiRatingView;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelTaper;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelSource;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelLineage;

- (void)updateCellWithSource:(IGShow *)source;

@end
