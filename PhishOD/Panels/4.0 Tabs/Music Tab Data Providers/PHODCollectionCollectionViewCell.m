//
//  PHODCollectionCollectionViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODCollectionCollectionViewCell.h"

#import "PhishAlbumArtCache.h"

NSMutableArray *phish_album_jokes = nil;
NSUInteger jokeNextIndex = 0;

@implementation PHODCollectionCollectionViewCell

+ (void)initialize {
    phish_album_jokes = @[
                          @"carini got your album art",
                          @"this album art is lost in gamehendge",
                          @"sorry, the album art has gone phishin'",
                          @"jim ran away with the album art",
                          @"if i could, i would bring you album art",
                          @"you enjoy my placeholder album art",
                          @"an asteroid crashed and the album art burned",
                          @"i'd like to weigh this album art",
                          @"this album art left chicago...",
                          @"this album art is with icculus now",
                          @"this album art got rained out.",
                          @"this album art will fuck your face",
                          @"this album art couldn't get a ticket in time.",
                          @"this album art got too high before the show",
                          @"this album art is still mourning jerrys death",
                          @"this album art is stuck in the line to the bathroom",
                          @"this album art is waiting for the parking lot to empty.",
                          @"this is this album art.",
                          @"this album art is still trying to scalp a ticket",
                          @"this album art is unavailable. It happens to me all the time.",
                          @"this album art is getting checked by a neurologist",
                          @"this album art is not of this earth",
                          @"this album art is over there in her incredible clothes",
                          @"this album art just isn't that into \"jam\"",
                          @"this album art got its bootleg tapes too close to a magnet",
                          @"this album art is at kill devil falls",
                          @"this album art thinks the studio albums are better.",
                          @"this album art DAVID BOWIE",
                          @"this album art is home on the train",
                          @"this album art is Cadillac rainbows and lots of spaghetti",
                          @"this album art is down at the central part of town",
                          @"this album art is a picture of odis redding",
                          @"this album art is stuck in a vacuum cleaner",
                          ].mutableCopy;
    
    NSUInteger count = phish_album_jokes.count;
    for (NSUInteger i = 0; i < count - 1; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [phish_album_jokes exchangeObjectAtIndex:i
                               withObjectAtIndex:exchangeIndex];
    }
    
    jokeNextIndex = arc4random_uniform((u_int32_t)phish_album_jokes.count);
}

+ (NSString *)nextAlbumArtJoke {
    NSString *joke = phish_album_jokes[jokeNextIndex];
    
    jokeNextIndex = (jokeNextIndex + 1) % phish_album_jokes.count;
    
    return joke;
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
//	[self.uiImageView sd_cancelCurrentImageLoad];
}

- (void)updateWithCollection:(id<PHODCollection>)col {
    self.uiImageView.image = nil;
    self.uiFauxAlbumArtSubtext.text = [self.class nextAlbumArtJoke];
    self.uiFauxAlbumArt.hidden = YES;
    self.uiActivityIndicator.hidden = NO;

    PhishAlbumArtCache *c = PhishAlbumArtCache.sharedInstance;
    
    [c.sharedCache asynchronouslyRetrieveImageForEntity:col
                                         withFormatName:PHODImageFormatSmall
                                        completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                            self.uiImageView.image = image;
                                            self.uiActivityIndicator.hidden = YES;
//                                            self.uiFauxAlbumArt.hidden = YES;
                                            
                                            [self.uiImageView.layer addAnimation:[CATransition animation]
                                                                          forKey:kCATransition];
                                        }];

	self.uiTitleLabel.text = col.displayText;
	self.uiSubtitleLabel.text = col.displaySubtext;
}

@end
