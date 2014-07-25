//
//  LargeImageTableViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LargeImageTableViewCell.h"

@implementation LargeImageTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(5,5,88,88 - 10);
    float limgW =  self.imageView.image.size.width;
    if(limgW > 0) {
        self.textLabel.frame = CGRectMake(55 + (88 - 40),self.textLabel.frame.origin.y,MAX(180,self.textLabel.frame.size.width),self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(55 + (88 - 40),self.detailTextLabel.frame.origin.y,MAX(180, self.detailTextLabel.frame.size.width),self.detailTextLabel.frame.size.height);
    }
}

@end
