//
//  LivePhishReviewsViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LivePhishCompleteContainer;

@interface LivePhishReviewsViewController : UITableViewController

- (instancetype)initWithCompleteContainer:(LivePhishCompleteContainer *)container;

@end
