//
//  SongInstancesViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongInstancesViewController : UITableViewController

@property PhishSong *song;
@property NSArray *indicies;

- (id)initWithSong:(PhishSong*) s;

@end
