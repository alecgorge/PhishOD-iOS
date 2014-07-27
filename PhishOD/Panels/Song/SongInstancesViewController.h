//
//  SongInstancesViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshableTableViewController.h"

@interface SongInstancesViewController : RefreshableTableViewController {
	UISegmentedControl *control;
	NSArray *filteredSongs;
}

@property PhishinSong *song;
@property NSArray *indicies;

- (id)initWithSong:(PhishinSong*) s;

@end
