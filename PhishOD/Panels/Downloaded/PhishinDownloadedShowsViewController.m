//
//  PhishinDownloadedShowsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/1/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinDownloadedShowsViewController.h"

#import "ShowViewController.h"
#import "PhishinAPI.h"
#import "ShowCell.h"

@interface PhishinDownloadedShowsViewController ()

@property (nonatomic) NSArray *shows;

@end

@implementation PhishinDownloadedShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Downloaded Shows";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ShowCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"showCell"];
}

- (void)refresh:(id)sender {
	[PhishinDownloadItem showsWithCachedTracks:^(NSArray *shows) {
		self.shows = [shows sortedArrayUsingComparator:^NSComparisonResult(PhishinShow *s1, PhishinShow *s2) {
			return [s2.date compare:s1.date];
		}];
		
		[self.tableView reloadData];
		[super refresh:sender];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"
													 forIndexPath:indexPath];
    
    PhishinShow *show = self.shows[indexPath.row];
	[cell updateCellWithShow:show
				 inTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"];
	
    PhishinShow *show = self.shows[indexPath.row];
	return [cell heightForCellWithShow:show
						   inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
    PhishinShow *show = self.shows[indexPath.row];
	ShowViewController *vc = [ShowViewController.alloc initWithCompleteShow:show];
	
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end
