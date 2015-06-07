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

@property (nonatomic) BOOL skipFirstLoad;

@end

@implementation TopRatedViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = @"Top Rated";
    }
    return self;
}

- (instancetype)initWithTopShows:(NSArray *)shows {
	if (self = [self init]) {
		self.topShows = shows;
		
		if(self.topShows != nil) {
			self.skipFirstLoad = YES;			
		}
	}
	return self;
}

- (void)refresh:(id)sender {
	if(self.skipFirstLoad) {
		[super refresh:sender];
		self.skipFirstLoad = NO;
		return;
	}
	
	[[PhishNetAPI sharedAPI] topRatedShowsWithSuccess:^(NSArray *t) {
		self.topShows = t;
		[self.tableView reloadData];
		[super refresh:sender];
	}
											  failure:REQUEST_FAILED(self.tableView)];
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
	PhishinShow *show = [[PhishinShow alloc] init];
	show.date = topShow.showDate;
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
										 animated:YES];
}

@end
