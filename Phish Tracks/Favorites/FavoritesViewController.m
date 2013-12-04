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
//	UITableViewStyle style = isAuthenticated ? UITableViewStylePlain : UITableViewStyleGrouped;

//	self = [super initWithStyle:style];
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
//		if (isAuthenticated) {
//			self.title = [NSString stringWithFormat:@"%@'s Favorites", [PhishTracksStats sharedInstance].username];
//		}
//		else {
			self.title = @"Favorites";
//		}
    }
    return self;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

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
//        return @"Favorites";
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
