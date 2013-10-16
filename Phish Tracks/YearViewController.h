//
//  YearViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshableTableViewController.h"

@interface YearViewController : RefreshableTableViewController {
	UISegmentedControl *control;
	NSArray *filteredShows;
}

@property PhishinYear *year;

@property (nonatomic, readonly) NSArray *shows;

-(id)initWithYear:(PhishinYear *)y;

@end
