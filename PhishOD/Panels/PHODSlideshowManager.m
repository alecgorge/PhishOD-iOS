//
//  PHODSlideshowManager.m
//  PhishOD
//
//  Created by Alec Gorge on 11/13/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODSlideshowManager.h"

#import "PHODSlideshowTitleView.h"

#import <CPKenburnsSlideshowView/CPKenBurnsImage.h>
#import <SDWebImage/SDWebImageManager.h>
#import <NSMutableArray-Shuffle/NSMutableArray+Shuffle.h>

@interface PHODSlideshowManager () <CPKenburnsSlideshowViewDeleagte>

@property (atomic) NSInteger restartCount;

@end

@implementation PHODSlideshowManager

- (instancetype)initWithWindow:(UIWindow *)window {
    if (self = [super init]) {
        self.window = window;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    NSArray *a = [NSUserDefaults.standardUserDefaults objectForKey:@"images"];
	
	self.restartCount = 3;
    
    self.images = [a map:^id(NSDictionary *object) {
        CPKenburnsImage *i = CPKenburnsImage.alloc.init;
        
        i.imageUrl = [NSURL URLWithString:object[@"url"]];
        i.title = object[@"title"];
        i.subTitle = object[@"owner"];
        
        return i;
    }].mutableCopy;
    
    [self.images shuffle];
    
    self.slideshow = [CPKenburnsSlideshowView.alloc initWithFrame:self.window.bounds];
    self.slideshow.delegate = self;
	self.slideshow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    self.slideshow.coverImage = [UIImage imageNamed:@"15115437744_51db659feb_b.jpg"];
    
    self.slideshow.slideshowDuration = 20.0f;
    self.slideshow.automaticFadeDuration = 4.0f;
	
	[self preloadImages];
    self.slideshow.titleViewClass = PHODSlideshowTitleView.class;
    
    [self.slideshow restartAnimation];
    [self.slideshow showCoverImage:YES];
    
    UIView *overlay = [UIView.alloc initWithFrame:self.window.bounds];
    overlay.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
	overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    [self.window addSubview:self.slideshow];
    [self.window addSubview:overlay];

    [self.window sendSubviewToBack:overlay];
    [self.window sendSubviewToBack:self.slideshow];
}

- (void)preloadImages {
	SDWebImageManager *manager = SDWebImageManager.sharedManager;

	for(NSInteger i = 0; i < (self.images.count < 3 ? self.images.count : 3); i++) {
		CPKenburnsImage *im = self.images[i];
		[manager downloadImageWithURL:im.imageUrl
							  options:0
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
								 // progression tracking code
							 }
							completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
								if(image) {
									self.restartCount--;
									
									if(self.restartCount == 0) {
										[self.slideshow showCoverImage:NO];
										[self.slideshow restartAllKenburnsMotion];
										self.slideshow.images = self.images;
									}
								}
								else {
									dbug(@"flickr err: %@ %@ %d %@", image, error, finished, imageURL);
								}
							}];
	}
}

- (void)slideshowView:(CPKenburnsSlideshowView *)slideshowView
 willShowKenBurnsView:(CPKenburnsView *)kenBurnsView {
    kenBurnsView.animationDuration = 30.f;
    kenBurnsView.startZoomRate = 1;
    kenBurnsView.endZoomRate = 1;
}

- (void)slideshowView:(CPKenburnsSlideshowView *)slideshowView
     downloadImageUrl:(NSURL *)imageUrl
      completionBlock:(DownloadCompletionBlock)completionBlock {
    SDWebImageManager *manager = SDWebImageManager.sharedManager;
    
//    dbug(@"requested url: %@", imageUrl);
    [manager downloadImageWithURL:imageUrl
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             // progression tracking code
                         }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if(image) {
                                completionBlock(image);
                            }
                            else {
                                dbug(@"flickr err: %@ %@ %d %@", image, error, finished, imageUrl);
                            }
                        }];
}

@end
