//
//  PhishNetNewsViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/30/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface PhishNetNewsViewController : RefreshableTableViewController

- (instancetype)initWithNews:(NSArray *)array;

@end
