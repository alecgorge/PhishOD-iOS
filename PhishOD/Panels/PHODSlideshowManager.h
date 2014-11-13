//
//  PHODSlideshowManager.h
//  PhishOD
//
//  Created by Alec Gorge on 11/13/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CPKenburnsSlideshowView/CPKenburnsSlideshowView.h>

@interface PHODSlideshowManager : NSObject

@property (nonatomic) UIWindow *window;
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) CPKenburnsSlideshowView *slideshow;

- (instancetype)initWithWindow:(UIWindow *)window;

@end
