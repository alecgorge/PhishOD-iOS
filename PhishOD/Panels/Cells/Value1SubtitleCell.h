//
//  Value1SubtitleCell.h
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Value1SubtitleCell : UITableViewCell

+ (CGFloat)height;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *value1Label;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end
