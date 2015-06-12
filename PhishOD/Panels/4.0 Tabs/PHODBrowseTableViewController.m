
//
//  PHODBrowseTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODBrowseTableViewController.h"

#import "YearsViewController.h"
#import "VenuesViewController.h"
#import "SongsViewController.h"
#import "CuratedPlaylistsViewController.h"
#import "ToursViewController.h"
#import "RandomShowViewController.h"

NS_ENUM(NSInteger, kPHODBrowseRows) {
	kPHODBrowseRandomShowRow,
	kPHODBrowsePlaylistsRow,
	kPHODBrowseYearsRow,
	kPHODBrowseVenuesRow,
	kPHODBrowseSongsRow,
	kPHODBrowseToursRow,
	kPHODBrowseRowCount,
};

@interface PHODBrowseTableViewController ()

@end

@implementation PHODBrowseTableViewController

- (instancetype)init {
	if (self = [super init]) {
		// set up tab bar
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Browse"
													  image:[UIImage imageNamed:@"glyphicons-58-history"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = @"Browse Phish";
	
	[self.tableView registerClass:UITableViewCell.class
		   forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kPHODBrowseRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
															forIndexPath:indexPath];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.row == kPHODBrowseRandomShowRow) {
		cell.textLabel.text = @"Random Show";
	}
	else if(indexPath.row == kPHODBrowsePlaylistsRow) {
		cell.textLabel.text = @"Curated Playlists";
	}
	else if(indexPath.row == kPHODBrowseYearsRow) {
		cell.textLabel.text = @"Years";
	}
	else if(indexPath.row == kPHODBrowseVenuesRow) {
		cell.textLabel.text = @"Venues";
	}
	else if(indexPath.row == kPHODBrowseSongsRow) {
		cell.textLabel.text = @"Songs";
	}
	else if(indexPath.row == kPHODBrowseToursRow) {
		cell.textLabel.text = @"Tours";
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.row == kPHODBrowseRandomShowRow) {
		[self pushViewController:[[RandomShowViewController alloc] init]];
	}
	else if(indexPath.row == kPHODBrowsePlaylistsRow) {
		[self pushViewController:[[CuratedPlaylistsViewController alloc] init]];
	}
	else if(indexPath.row == kPHODBrowseYearsRow) {
		[self pushViewController:[[YearsViewController alloc] init]];
	}
	else if(indexPath.row == kPHODBrowseVenuesRow) {
		[self pushViewController:[[VenuesViewController alloc] init]];
	}
	else if(indexPath.row == kPHODBrowseSongsRow) {
		[self pushViewController:[[SongsViewController alloc] init]];
	}
	else if(indexPath.row == kPHODBrowseToursRow) {
		[self pushViewController:[[ToursViewController alloc] init]];
	}
}

- (void)pushViewController:(UIViewController*)vc {
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end
