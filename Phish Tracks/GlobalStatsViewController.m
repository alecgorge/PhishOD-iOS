//
//  GlobalStatsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "GlobalStatsViewController.h"
#import "PhishTracksStats.h"
#import "ShowViewController.h"

@interface GlobalStatsViewController ()

@end

@implementation GlobalStatsViewController

- (void)viewDidLoad {
	self.title = @"Global Stats";
	[super viewDidLoad];
}

- (void)refresh:(id)sender {
	[[PhishTracksStats sharedInstance] globalStats:^(NSDictionary *stats, NSArray *history) {
		self.stats = stats;
		self.history = history;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[super refresh:sender];
			[self.tableView reloadData];
		});
	}
										   failure:REQUEST_FAILED(self.tableView)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.stats == nil ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 2;
	}
	else if(section == 1) {
		return self.history == nil ? 0 : self.history.count;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1Cell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"value1Cell"];
		}
		
		if(indexPath.section == 0 && indexPath.row == 0) {
			cell.textLabel.text = @"Total Plays";
			cell.detailTextLabel.text = [self.stats[@"play_count"] stringValue];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if(indexPath.section == 0 && indexPath.row == 1) {
			cell.textLabel.text = @"Playback Time";
			cell.detailTextLabel.text = self.stats[@"total_time_formatted"];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		return cell;
	}
	else if(indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subtitleCell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										  reuseIdentifier:@"subtitleCell"];
		}
		
		PhishTracksStatsHistoryItem *item = self.history[indexPath.row];
		cell.textLabel.text = item.title;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - Played %@ times", item.showDate, item.playCount];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 1) {
		PhishTracksStatsHistoryItem *item = self.history[indexPath.row];
		PhishShow *show = [[PhishShow alloc] init];
		show.showDate = item.showDate;
		[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
											 animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		return tableView.rowHeight * 1.3;
	}
	
	return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 1) {
		return @"Top Tracks";
	}
	return nil;
}

@end
