//
//  ShowViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConcertInfoViewController.h"
#import "ReviewsViewController.h"
#import "RefreshableTableViewController.h"
#import "PhishinStreamingPlaylistItem.h"

@interface ShowViewController : RefreshableTableViewController

@property (nonatomic) UISegmentedControl *control;
@property (nonatomic) PhishinShow *show;
@property (nonatomic) PhishNetSetlist *setlist;

@property (nonatomic) BOOL autoplay;
@property (nonatomic) NSInteger autoplayTrackId;
@property (nonatomic) NSTimeInterval autoplaySeekLocation;

- (id)initWithShow:(PhishinShow*) s;
- (id)initWithShowDate:(NSString *)showDate;

@end
