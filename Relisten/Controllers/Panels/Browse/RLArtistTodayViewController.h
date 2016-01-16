//
//  RLArtistTodayViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 1/16/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RefreshableTableViewController.h"

@class IGTodayShow;

@interface RLArtistTodayViewController : RefreshableTableViewController

- (instancetype)initWithArtistName:(NSString *)artistName;

@property (nonatomic, copy) void(^showSelectionCallback)(IGTodayShow *);

@end
