//
//  IGReviewCell.h
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGAPIClient.h"

@interface IGReviewCell : UITableViewCell

- (void)updateCellWithReview:(IGShowReview *)review
                 inTableView:(UITableView *)tableView;

@end
