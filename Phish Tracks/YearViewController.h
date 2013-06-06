//
//  YearViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YearViewController : UITableViewController {
	UISegmentedControl *control;
	NSArray *filteredShows;
}

@property PhishYear *year;

-(id)initWithYear:(PhishYear *)y;

@end
