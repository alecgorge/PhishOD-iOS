//
//  VenueViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDLocationsMapViewController.h"

@interface VenueViewController : PDLocationsMapViewController <PDLocationsMapDataSource, PDLocationsMapDelegate>

- (instancetype)initWithVenue:(PhishinVenue*)venue;

@property (nonatomic) PhishinVenue *venue;

@end
