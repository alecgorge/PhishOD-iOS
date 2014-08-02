//
//  ConcertInfoViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongStringViewController : UITableViewController

@property (nonatomic) BOOL monospace;

- (id)initWithString:(NSString*)s;

@end
