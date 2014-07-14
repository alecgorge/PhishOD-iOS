//
//  TourViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearViewController.h"

@interface TourViewController : YearViewController

- (instancetype)initWithTour:(PhishinTour*)tour;

@property (nonatomic) PhishinTour *tour;

@end
