//
//  PHODCollectionCollectionViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODCollectionCollectionViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@implementation PHODCollectionCollectionViewCell

+ (CGSize)itemSize {
	return CGSizeMake(112, 148);
}

+ (CGFloat)rowHeight {
	return 157;
}

- (void)awakeFromNib {
}

- (void)prepareForReuse {
	[self.uiImageView sd_cancelCurrentImageLoad];
}

- (void)updateWithCollection:(id<PHODCollection>)col {
	[self.uiImageView setImageWithURL:[col albumArt]
		  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	self.uiTitleLabel.text = col.displayText;
	self.uiSubtitleLabel.text = col.displaySubtext;
}

@end
