//
//  JamChartEntryViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JamChartEntryViewController : UITableViewController

- (instancetype)initWithJamChartEntry:(PhishNetJamChartEntry *)entry
							 andTrack:(PhishinTrack *)track;

@end
