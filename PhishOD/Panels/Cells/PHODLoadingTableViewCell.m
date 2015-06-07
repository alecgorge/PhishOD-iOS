//
//  PHODLoadingTableViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODLoadingTableViewCell.h"

@implementation PHODLoadingTableViewCell

- (void)awakeFromNib {
	[self.uiActivityIndicator startAnimating];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
