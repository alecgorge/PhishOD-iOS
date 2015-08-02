//
//  PHODDownloadTabTableViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 6/9/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface PHODDownloadTabTableViewController :
#ifdef IS_PHISH
    UITableViewController
#else
    RefreshableTableViewController
#endif

@end
