//
//  LivePhishDownloadedShowsViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 8/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

#import "UIScrollView+EmptyDataSet.h"

@interface LivePhishDownloadedShowsViewController : RefreshableTableViewController<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end
