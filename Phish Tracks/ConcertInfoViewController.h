//
//  ConcertInfoViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConcertInfoViewController : UITableViewController

@property PhishNetSetlist *setlist;

- (id)initWithSetlist:(PhishNetSetlist*)s;

@end
