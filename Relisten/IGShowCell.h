//
//  IGShowCell.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AXRatingView/AXRatingView.h>

#import "IGAPIClient.h"

@interface IGShowCell : UITableViewCell

- (void)updateCellWithShow:(IGShow *)show;

+ (CGFloat)height;

@end
