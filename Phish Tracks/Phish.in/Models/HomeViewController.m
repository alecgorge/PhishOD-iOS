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
#import "FavoritesViewController.h"
#import "GlobalActivityViewController.h"

typedef enum {
	kPhishODMenuItemYears,
	kPhishODMenuItemSongs,
	kPhishODMenuItemVenues,
	kPhishODMenuItemTours,
	kPhishODMenuItemTopRated,
	kPhishODMenuItemRandomShow,
	kPhishODMenuItemsCount
} kPhishODMenuItems;

typedef enum {
	kPhishODMenuStatsItemFavorites,
	kPhishODMenuStatsItemGlobalActivity,
	kPhishODMenuStatsItemsCount
} kPhishODMenuStatsItems;

typedef enum {
	kPhishODMenuSectionNowPlaying,
	kPhishODMenuSectionMenu,
	kPhishODMenuSectionStats,
	kPhishODMenuSectionsCount
} kPhishODMenuSections;

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
	return kPhishODMenuSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == kPhishODMenuSectionNowPlaying) {
		return 1;
	}
	else if(section == kPhishODMenuSectionMenu) {
		return kPhishODMenuItemsCount;
	}
	
	return kPhishODMenuStatsItemsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:@"cell"];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if(indexPath.section == kPhishODMenuSectionNowPlaying) {
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
	int section = indexPath.section;
	if (section == kPhishODMenuSectionMenu && row == kPhishODMenuItemYears) {
		cell.textLabel.text = @"Years";
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemSongs) {
		cell.textLabel.text = @"Songs";
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemVenues) {
		cell.textLabel.text = @"Venues";
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemTours) {
		cell.textLabel.text = @"Tours";
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemTopRated) {
		cell.textLabel.text = @"Top Rated Shows";
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemRandomShow) {
		cell.textLabel.text = @"Random Show";
	}
	else if(section == kPhishODMenuSectionStats && row == kPhishODMenuStatsItemFavorites) {
		cell.textLabel.text = @"Favorites";
	}
	else if(section == kPhishODMenuSectionStats && row == kPhishODMenuStatsItemGlobalActivity) {
		cell.textLabel.text = @"Recent Activity";
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0 && [AppDelegate sharedDelegate].currentlyPlayingShow != nil) {
		[self pushViewController:[[ShowViewController alloc] initWithShow:AppDelegate.sharedDelegate.currentlyPlayingShow]];
		return;
	}
	
	int row = indexPath.row;
	int section = indexPath.section;
	if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemYears) {
		[self pushViewController:[[YearsViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemSongs) {
		[self pushViewController:[[SongsViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemVenues) {
		[self pushViewController:[[VenuesViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemTours) {
		[self pushViewController:[[ToursViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemTopRated) {
		[self pushViewController:[[TopRatedViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionMenu && row == kPhishODMenuItemRandomShow) {
		[self pushViewController:[[RandomShowViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionStats && row == kPhishODMenuStatsItemFavorites) {
		[self pushViewController:[[FavoritesViewController alloc] init]];
	}
	else if(section == kPhishODMenuSectionStats && row == kPhishODMenuStatsItemGlobalActivity) {
		[self pushViewController:[[GlobalActivityViewController alloc] init]];
	}
}

- (void)pushViewController:(UIViewController*)vc {
	[self.navigationController pushViewController:vc
										 animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == kPhishODMenuSectionStats) {
		return @"Stats";
	}
	return nil;
}

@end
