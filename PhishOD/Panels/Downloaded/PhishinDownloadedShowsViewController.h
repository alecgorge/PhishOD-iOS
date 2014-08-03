//
//  PhishinDownloadedShowsViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 8/1/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import "UIScrollView+EmptyDataSet.h"

@interface PhishinDownloadedShowsViewController : RefreshableTableViewController<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end
