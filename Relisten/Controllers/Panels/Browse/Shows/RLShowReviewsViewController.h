//
//  RLShowReviewsViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class IGShow;

@interface RLShowReviewsViewController : UITableViewController

- (instancetype)initWithShow:(IGShow *)show;

@end
