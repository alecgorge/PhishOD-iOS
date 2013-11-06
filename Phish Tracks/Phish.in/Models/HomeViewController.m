//
//  HomeViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/29/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"
#import "YearsViewController.h"
#import "SongsViewController.h"
#import "ToursViewController.h"
#import "TopRatedViewController.h"
#import "PhishTracksStatsViewController.h"
#import "SettingsViewController.h"
#import "VenuesViewController.h"
#import "SearchViewController.h"
#import "RandomShowViewController.h"
#import "SearchDelegate.h"

typedef enum {
	kPhishODMenuItemYears,
	kPhishODMenuItemSongs,
	kPhishODMenuItemVenues,
	kPhishODMenuItemTours,
	kPhishODMenuItemTopRated,
	kPhishODMenuItemRandomShow,
	kPhishODMenuItemsCount
} kPhishODMenuItems;

@interface HomeViewController ()

@property (nonatomic) UISearchDisplayController *con;
@property (nonatomic) SearchDelegate *conDel;
@property (nonatomic) UISearchBar *searchBar;

@end

@implementation HomeViewController

- (void)createSearchBar {
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
	
	self.con = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
												 contentsController:self];
	
	self.conDel = [[SearchDelegate alloc] initWithTableView:self.searchDisplayController.searchResultsTableView
									andNavigationController:self.navigationController];
	
	self.searchDisplayController.searchResultsDelegate = self.conDel;
	self.searchDisplayController.searchResultsDataSource = self.conDel;
	self.searchDisplayController.delegate = self.conDel;
	
	self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"PhishOD";
	[self createSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

-(void)dealloc {
	self.con = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 1;
	}
	
	return kPhishODMenuItemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:@"cell"];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.section == 0) {
		PhishinShow *show = [AppDelegate sharedDelegate].currentlyPlayingShow;
		
		cell.textLabel.text = @"Now Playing";

		if(show != nil) {
			cell.detailTextLabel.text = show.date;
		}
		else {
			cell.detailTextLabel.text = @"Nothing yet...";
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		return cell;
	}
	
	int row = indexPath.row;
	if (row == kPhishODMenuItemYears) {
		cell.textLabel.text = @"Years";
	}
	else if(row == kPhishODMenuItemSongs) {
		cell.textLabel.text = @"Songs";
	}
	else if(row == kPhishODMenuItemVenues) {
		cell.textLabel.text = @"Venues";
	}
	else if(row == kPhishODMenuItemTours) {
		cell.textLabel.text = @"Tours";
	}
	else if(row == kPhishODMenuItemTopRated) {
		cell.textLabel.text = @"Top Rated Shows";
	}
	else if(row == kPhishODMenuItemRandomShow) {
		cell.textLabel.text = @"Random Show";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0) {
		[self pushViewController:[[ShowViewController alloc] initWithShow:AppDelegate.sharedDelegate.currentlyPlayingShow]];
		return;
	}
	
	int row = indexPath.row;
	if(row == kPhishODMenuItemYears) {
		[self pushViewController:[[YearsViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemSongs) {
		[self pushViewController:[[SongsViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemVenues) {
		[self pushViewController:[[VenuesViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemTours) {
		[self pushViewController:[[ToursViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemTopRated) {
		[self pushViewController:[[TopRatedViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemRandomShow) {
		[self pushViewController:[[RandomShowViewController alloc] init]];
	}
}

- (void)pushViewController:(UIViewController*)vc {
	[self.navigationController pushViewController:vc
										 animated:YES];
}


@end
