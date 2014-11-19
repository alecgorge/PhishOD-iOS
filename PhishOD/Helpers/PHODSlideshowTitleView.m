//
//  PHODSlideshowTitleView.m
//  PhishOD
//
//  Created by Alec Gorge on 11/13/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODSlideshowTitleView.h"

@implementation PHODSlideshowTitleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureView {
    [super configureView];
	self.backgroundColor = UIColor.clearColor;
	self.opaque = NO;
	
	self.titleLabel.font = [UIFont systemFontOfSize:13.0];
	self.subTitleLabel.font = [UIFont systemFontOfSize:13.0];
	
	self.titleLabel.frame = CGRectMake(15, CGRectGetHeight(self.bounds) - 130, 250, 20);
	self.subTitleLabel.frame = CGRectMake(15, CGRectGetHeight(self.bounds) - 115, 250, 20);
	
	self.titleLabel.textColor = UIColor.whiteColor;
	self.subTitleLabel.textColor = UIColor.whiteColor;
}

- (void)setImageObject:(CPKenburnsImage *)imageObject {
    [super setImageObject:imageObject];
}

@end
