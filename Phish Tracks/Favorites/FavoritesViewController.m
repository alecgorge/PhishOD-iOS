//
//  FavoritesViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PhishTracksStats.h"
#import "FavoriteTracksViewController.h"
#import "FavoriteShowsViewController.h"
#import "FavoriteToursViewController.h"
#import "FavoriteVenuesViewController.h"

typedef enum {
	kStatsFavoritesViewTracksMenuItem,
	kStatsFavoritesViewShowsMenuItem,
	kStatsFavoritesViewToursMenuItem,
	kStatsFavoritesViewVenuesMenuItem,
	kStatsFavoritesViewMenuItemCount
} StatsFavoritesViewMenuItems;

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController {
	BOOL isAuthenticated;
}

- (id)init
{
	isAuthenticated = [PhishTracksStats sharedInstance].isAuthenticated;

	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Favorites";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (isAuthenticated) {
		return kStatsFavoritesViewMenuItemCount;
	}
	else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	if (indexPath.section == 0) {
		if (indexPath.row == kStatsFavoritesViewTracksMenuItem) {
			cell.textLabel.text = @"Tracks";
		}
		else if (indexPath.row == kStatsFavoritesViewShowsMenuItem) {
			cell.textLabel.text = @"Shows";
		}
		else if (indexPath.row == kStatsFavoritesViewToursMenuItem) {
			cell.textLabel.text = @"Tours";
		}
		else if (indexPath.row == kStatsFavoritesViewVenuesMenuItem) {
			cell.textLabel.text = @"Venues";
		}
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 0) {
		if (indexPath.row == kStatsFavoritesViewTracksMenuItem) {
            [self.navigationController pushViewController:[[FavoriteTracksViewController alloc] init] animated:YES];
		}
		else if (indexPath.row == kStatsFavoritesViewShowsMenuItem) {
            [self.navigationController pushViewController:[[FavoriteShowsViewController alloc] init] animated:YES];
		}
		else if (indexPath.row == kStatsFavoritesViewToursMenuItem) {
            [self.navigationController pushViewController:[[FavoriteToursViewController alloc] init] animated:YES];
		}
		else if (indexPath.row == kStatsFavoritesViewVenuesMenuItem) {
            [self.navigationController pushViewController:[[FavoriteVenuesViewController alloc] init] animated:YES];
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isAuthenticated)
        return [NSString stringWithFormat:@"%@'s Favorites", [PhishTracksStats sharedInstance].username];
    else
        return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (!isAuthenticated) {
		return @"Sign up under 'Stats & Favorites' in the Settings tab to get favorites.";
	}
	else {
		return nil;
	}
}

@end
