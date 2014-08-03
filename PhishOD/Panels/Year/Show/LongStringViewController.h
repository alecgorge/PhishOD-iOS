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

- (instancetype)initWithString:(NSString*)s;
- (instancetype)initWithAttributedString:(NSAttributedString*)s;
- (instancetype)initWithHTML:(NSString*)s;

@end
