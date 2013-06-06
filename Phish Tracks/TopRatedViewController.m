//
//  TopRatedViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TopRatedViewController.h"
#import "ShowViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface TopRatedViewController ()

@end

@implementation TopRatedViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = @"Top Rated";
		
		TopRatedViewController *i = self;
		[self.tableView addPullToRefreshWithActionHandler:^{
			[[PhishNetAPI sharedAPI] topRatedShowsWithSuccess:^(NSArray *t) {
				i.topShows = t;
				[i.tableView reloadData];
				[i.tableView.pullToRefreshView stopAnimating];
			}
													  failure:REQUEST_FAILED(i.tableView)];
		}];
		
		[self.tableView triggerPullToRefresh];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.topShows != nil ? self.topShows.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:CellIdentifier];
	}
    
	PhishNetTopShow *show = self.topShows[indexPath.row];
    cell.textLabel.text = show.showDate;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@ ratings)", show.rating, show.ratingCount];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishNetTopShow *topShow = self.topShows[indexPath.row];
	PhishShow *show = [[PhishShow alloc] init];
	show.showDate = topShow.showDate;
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
										 animated:YES];
}

@end
