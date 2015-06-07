//
//  PHODCollectionCollectionViewCell.h
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PHODCollection.h"

@interface PHODCollectionCollectionViewCell : UICollectionViewCell

+ (CGSize)itemSize;
+ (CGFloat)rowHeight;

@property (weak, nonatomic) IBOutlet UIImageView *uiImageView;
@property (weak, nonatomic) IBOutlet UILabel *uiTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiSubtitleLabel;

- (void)updateWithCollection:(id<PHODCollection>)col;

@end
