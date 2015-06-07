//
//  PHODCollectionTableViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODCollectionTableViewCell.h"

#import "PHODCollectionCollectionViewCell.h"

@implementation PHODCollectionTableViewCell

- (void)awakeFromNib {
    [self.uiCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODCollectionCollectionViewCell.class)
													  bundle:nil]
			forCellWithReuseIdentifier:@"PHODCollectionCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
