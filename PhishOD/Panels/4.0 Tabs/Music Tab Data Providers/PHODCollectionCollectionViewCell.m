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

NSArray *phish_album_jokes = nil;

@implementation PHODCollectionCollectionViewCell

+ (void)initialize {
    phish_album_jokes = @[
                          @"carini got your album art",
                          @"this album art is lost in gamehendge",
                          @"sorry, the album art has gone phishin'",
                          @"jim ran away with the album art",
                          @"if i could, i would bring you album art",
                          @"you enjoy my placeholder album art",
                          @"an asteroid crashed and     the album art burned",
                          @"i'd like to weigh this album art",
                          @"this album art left chicago...",
                          @"this album art is with icculus now"
                          ];
}

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
                     placeholderImage:nil
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                if (!image) {
                                    self.uiFauxAlbumArtSubtext.text = phish_album_jokes[arc4random_uniform((u_int32_t)phish_album_jokes.count)];
                                    
                                    self.uiFauxAlbumArt.hidden = NO;
                                }
                                else {
                                    self.uiImageView.image = image;
                                    self.uiFauxAlbumArt.hidden = YES;
                                }
                            }
          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	self.uiTitleLabel.text = col.displayText;
	self.uiSubtitleLabel.text = col.displaySubtext;
}

@end
