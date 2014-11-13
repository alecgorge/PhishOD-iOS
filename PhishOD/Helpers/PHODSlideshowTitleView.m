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
    //    self.titleLabel.backgroundColor = [UIColor grayColor];
}

- (void)setImageObject:(CPKenburnsImage *)imageObject {
    [super setImageObject:imageObject];
    self.titleLabel.text = imageObject.title;
}

@end
