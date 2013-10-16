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
#import "PhishTracksStatsViewController.h"
#import "SettingsViewController.h"
#import "VenuesViewController.h"

typedef enum {
	kPhishODMenuItemNowPlaying,
	kPhishODMenuItemYears,
	kPhishODMenuItemSongs,
	kPhishODMenuItemVenues,
	kPhishODMenuItemTours,
	kPhishODMenuItemTopRated,
	kPhishODMenuItemStats,
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
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
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
	else if(row == kPhishODMenuItemStats) {
		cell.textLabel.text = @"Stats";
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
			cell.accessoryView = [[UIImageView alloc] initWithImage:[self maskImage:[UIImage imageNamed:@"glyphicons_174_pause.png"]
																		  withColor:COLOR_PHISH_WHITE]];
		}
		else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = @"Nothing playing...";
			cell.accessoryView = [[UIImageView alloc] initWithImage:[self maskImage:[UIImage imageNamed:@"glyphicons_173_play.png"]
																		  withColor:COLOR_PHISH_WHITE]];
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	int row = indexPath.row;
	if(row == kPhishODMenuItemNowPlaying && self.item) {
		[[AppDelegate sharedDelegate] showNowPlaying];
	}
	else if(row == kPhishODMenuItemYears) {
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
	else if(row == kPhishODMenuItemStats) {
		[self pushViewController:[[PhishTracksStatsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
	}
	else if(row == kPhishODMenuItemSettings) {
		[self pushViewController:[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
	}
}

- (void)pushViewController:(UIViewController*)vc {
	UINavigationController *nav = (UINavigationController*)self.sidePanelController.centerPanel;
	nav.viewControllers = @[vc];
	nav.navigationBar.translucent = NO;
	
	[self.sidePanelController showCenterPanelAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = indexPath.row;
	if (row == kPhishODMenuItemNowPlaying) {
		return tableView.rowHeight * 3;
	}
	
	return UITableViewAutomaticDimension;
}

@end
