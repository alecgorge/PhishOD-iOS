//
//  PhishNetBlogViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface PhishNetBlogViewController : RefreshableTableViewController

- (instancetype)initWithBlog:(NSArray *)array;

@end
