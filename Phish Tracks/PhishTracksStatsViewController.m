//
//  PhishTracksStatsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsViewController.h"
#import "ShowViewController.h"
#import "GlobalStatsViewController.h"

@interface PhishTracksStatsViewController ()
@property BOOL showLoginMessage;
@end

@implementation PhishTracksStatsViewController

- (void)viewDidLoad {
	self.title = @"Stats";
	[super viewDidLoad];
}

- (void)refresh:(id)sender {
	self.showLoginMessage = NO;
	
	if([PhishTracksStats sharedInstance].username != nil) {
		[[PhishTracksStats sharedInstance] stats:^(NSDictionary *stats, NSArray *history) {
			self.stats = stats;
			self.history = history;
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[super refresh:sender];
				[self.tableView reloadData];
			});
		}
										 failure:REQUEST_FAILED(self)];
	}
	else {
		self.showLoginMessage = YES;
		[super refresh:sender];
		[self.tableView reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.showLoginMessage || self.stats == nil) {
		return 1;
	}

	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 1;
	}
	else if(section == 1) {
		return 2;
	}
	else if(section == 2) {
		return self.history == nil ? 0 : self.history.count;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"plainCell"];
		}
		
		if(indexPath.section == 0 && indexPath.row == 0) {
			cell.textLabel.text = @"View global stats";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		return cell;
	}
	else if(indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1Cell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"value1Cell"];
		}
		
		if(indexPath.section == 1 && indexPath.row == 0) {
			cell.textLabel.text = @"Plays";
			cell.detailTextLabel.text = self.stats[@"catalog_progress"];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if(indexPath.section == 1 && indexPath.row == 1) {
			cell.textLabel.text = @"Playback Time";
			cell.detailTextLabel.text = self.stats[@"total_time_formatted"];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	else if(indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subtitleCell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:@"subtitleCell"];
		}
		
		PhishTracksStatsHistoryItem *item = self.history[indexPath.row];
		cell.textLabel.text = item.title;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ ago", item.showDate, item.timeSincePlayed];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0 && indexPath.section == 0) {
		GlobalStatsViewController *g = [[GlobalStatsViewController alloc] initWithStyle: UITableViewStyleGrouped];
		[self.navigationController pushViewController:g
											 animated:YES];
	}
	else if(indexPath.section == 2) {
		PhishTracksStatsHistoryItem *item = self.history[indexPath.row];
		PhishShow *show = [[PhishShow alloc] init];
		show.showDate = item.showDate;
		[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
											 animated:YES];

	}
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 2) {
		return tableView.rowHeight * 1.3;
	}
	
	return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 1) {
		return [NSString stringWithFormat: @"Stats for %@", [PhishTracksStats sharedInstance].username];
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
	if(section == 0) {
		if(self.showLoginMessage)
			return @"If you would like personalized stats, sign in on the settings tab.";
		else
			return @"Stats provided by phishtrackstats.com";
	}
	return nil;
}

@end
