//
//  MenuPanel.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "MenuPanel.h"
#import "AppDelegate.h"

#import <JASidePanels/UIViewController+JASidePanel.h>

#import "YearsViewController.h"
#import "SongsViewController.h"
#import "ToursViewController.h"
#import "TopRatedViewController.h"
#import "SettingsViewController.h"
#import "VenuesViewController.h"
#import "SearchViewController.h"
#import "HomeViewController.h"

#import "AppDelegate.h"

#import "NavigationControllerAutoShrinkerForNowPlaying.h"

typedef enum {
	kPhishODMenuItemNowPlaying,
	kPhishODMenuItemHome,
	kPhishODMenuItemSettings,
	kPhishODMenuItemsCount
} kPhishODMenuItems;

@implementation MenuPanel

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	CGRect frame = self.tableView.bounds;
	frame.origin.y = -frame.size.height;
	UIView* grayView = [[UIView alloc] initWithFrame:frame];
	grayView.backgroundColor = COLOR_PHISH_GREEN;
	[self.tableView addSubview:grayView];
	
	CGRect old = self.view.frame;
	old.size.width = 256.0f;
	self.view.frame = old;
	CGRect told = self.tableView.frame;
	told.size.width = 256.0f;
	self.tableView.frame = told;
	[self.tableView layoutSubviews];
}

- (void)updateNowPlayingWithStreamingPlaylistItem:(StreamingPlaylistItem *)item {
	self.item = item;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return kPhishODMenuItemsCount;
}

- (UIImage*)maskImage:(UIImage*)image withColor:(UIColor*)color {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
	
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	return coloredImg;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:@"cell"];
	}
	
	NSInteger row = indexPath.row;

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	if (row == kPhishODMenuItemHome) {
		cell.textLabel.text = @"Music";
	}
	else if(row == kPhishODMenuItemSettings) {
		cell.textLabel.text = @"Settings";
	}
	else if(row == kPhishODMenuItemNowPlaying) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:@"NowPlaying"];
		
		cell.backgroundColor = COLOR_PHISH_GREEN;
		cell.textLabel.textColor = COLOR_PHISH_WHITE;
		cell.detailTextLabel.textColor = COLOR_PHISH_WHITE;

		if(self.item) {
			cell.textLabel.text = self.item.title;
			cell.textLabel.numberOfLines = 3;
			
			PhishinStreamingPlaylistItem *item = (PhishinStreamingPlaylistItem*)self.item;
			
			NSString *str = [NSString stringWithFormat:@"%@\n%@ - %@", item.track.show.date, item.track.show.venue.name, item.track.show.venue.location, nil];
			cell.detailTextLabel.text = str;
			cell.detailTextLabel.numberOfLines = 3;
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage playIconWhite]];
		}
		else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = @"Nothing playing.  Yet.";
            cell.detailTextLabel.numberOfLines = 2;
            cell.detailTextLabel.text = @"Feeling adventurous?\nTap here for a random show.";
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage playIconWhite]];
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == kPhishODMenuItemNowPlaying) {
		cell.backgroundColor = COLOR_PHISH_GREEN;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	NSInteger row = indexPath.row;
	if(row == kPhishODMenuItemNowPlaying) {
        if (self.item) {
            [[AppDelegate sharedDelegate] showNowPlaying];
        }
        else {
            [self pushViewControllerFromHome:[[RandomShowViewController alloc] init]];
        }
	}
	else if(row == kPhishODMenuItemHome) {
		[self pushViewController:[[HomeViewController alloc] init]];
	}
	else if(row == kPhishODMenuItemSettings) {
		[self pushViewController:[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
	}
}

- (void)pushViewController:(UIViewController*)vc {
	UINavigationController *nav = (UINavigationController*)self.sidePanelController.centerPanel;
	nav.viewControllers = @[vc];
	nav.navigationBar.translucent = NO;
    nav.delegate = AppDelegate.sharedDelegate.navDelegate;
	
	[self.sidePanelController showCenterPanelAnimated:YES];
}

- (void)pushViewControllerFromHome:(UIViewController *)vc {
    [self pushViewController:[[HomeViewController alloc] init]];
    
	UINavigationController *nav = (UINavigationController*)self.sidePanelController.centerPanel;
	HomeViewController *home = (HomeViewController *)nav.topViewController;
    home.title = @"PhishOD";
	
	[home.navigationController pushViewController:[[RandomShowViewController alloc] init] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	if (row == kPhishODMenuItemNowPlaying) {
		return tableView.rowHeight * 3;
	}
	
	return UITableViewAutomaticDimension;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return [UIView new];
//}

@end
