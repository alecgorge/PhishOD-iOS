//
//  PhishTracksStatsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsViewController.h"
#import "ShowViewController.h"
#import "UserTopTracksViewController.h"
#import "PlayHistoryViewController.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"
#import "PhishTracksStatsStat.h"
#import "StatsQueries.h"
#import "GlobalStatsViewController.h"

//@interface PhishTracksStatsViewController ()
//@property BOOL showLoginMessage;
//@end

@implementation PhishTracksStatsViewController {
	PhishTracksStatsQueryResults *userStats;
	PhishTracksStatsQuery *statsQuery;
	BOOL isAuthenticated;
}

- (id)init
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		statsQuery = [StatsQueries predefinedStatQuery:kUserAllTimeScalarStats];
		isAuthenticated = [PhishTracksStats sharedInstance].isAuthenticated;
		self.title = @"Stats";
	}

	return self;
}

//- (void)viewDidLoad {
//	[super viewDidLoad];
//}

- (void)refresh:(id)sender {
	if([PhishTracksStats sharedInstance].isAuthenticated) {
		[[PhishTracksStats sharedInstance] userStatsWithUserId:[PhishTracksStats sharedInstance].userId statsQuery:statsQuery
		success:^(PhishTracksStatsQueryResults *result)
	    {
			userStats = result;
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[super refresh:sender];
				[self.tableView reloadData];
			});
	    }
		failure:^(PhishTracksStatsError *error)
		{
			[self.refreshControl endRefreshing];
			[FailureHandler showAlertWithStatsError:error];
		}];
	}
	else {
		[super refresh:sender];
		[self.tableView reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(isAuthenticated) {
		return 2;
	}
	else
		return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 5;
	}

	if (isAuthenticated && userStats) {
		if(section == 1) {
			return userStats.scalarStatCount + 2;
		}
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"plainCell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"plainCell"];
		}
		
		if(indexPath.section == 0) {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Last hour";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if (indexPath.row == 1) {
				cell.textLabel.text = @"Today";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if (indexPath.row == 2) {
				cell.textLabel.text = @"This week";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if (indexPath.row == 3) {
				cell.textLabel.text = @"This month";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			else if (indexPath.row == 4) {
				cell.textLabel.text = @"All time";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		return cell;
	}
	else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1Cell"];
		
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"value1Cell"];
		}

		if (indexPath.row < userStats.scalarStatCount) {
			PhishTracksStatsStat *stat = [userStats getStatAtIndex:indexPath.row];

			cell.textLabel.text = stat.prettyName;
			cell.detailTextLabel.text = [stat valueAsString];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else if (indexPath.row == userStats.scalarStatCount) {
			cell.textLabel.text = @"Top Tracks";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (indexPath.row == userStats.scalarStatCount + 1) {
			cell.textLabel.text = @"Play History";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(indexPath.section == 0) {
		if(indexPath.row == 0) {
			GlobalStatsViewController *c = [[GlobalStatsViewController alloc] initWithTitle:@"Last hour"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalThisHour]];
			[self.navigationController pushViewController:c animated:YES];
		}
		else if(indexPath.row == 1) {
			GlobalStatsViewController *c = [[GlobalStatsViewController alloc] initWithTitle:@"Today"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalToday]];
			[self.navigationController pushViewController:c animated:YES];
		}
		else if(indexPath.row == 2) {
			GlobalStatsViewController *c = [[GlobalStatsViewController alloc] initWithTitle:@"This week"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalThisWeek]];
			[self.navigationController pushViewController:c animated:YES];
		}
		else if(indexPath.row == 3) {
			GlobalStatsViewController *c = [[GlobalStatsViewController alloc] initWithTitle:@"This month"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalThisMonth]];
			[self.navigationController pushViewController:c animated:YES];
		}
		else if(indexPath.row == 4) {
			GlobalStatsViewController *c = [[GlobalStatsViewController alloc] initWithTitle:@"All time"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalAllTime]];
			[self.navigationController pushViewController:c animated:YES];
		}
	}
	else if(indexPath.section == 1) {
		if (indexPath.row == userStats.scalarStatCount) {
			UserTopTracksViewController *c = [[UserTopTracksViewController alloc] init];
			[self.navigationController pushViewController:c animated:YES];
		}
		else if (indexPath.row == userStats.scalarStatCount + 1) {
			PlayHistoryViewController *c = [[PlayHistoryViewController alloc] init];
			[self.navigationController pushViewController:c animated:YES];
		}
	}
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	if(indexPath.section == 2) {
//		return tableView.rowHeight * 1.3;
//	}
//	
//	return UITableViewAutomaticDimension;
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Global Stats";
	}
	else if(isAuthenticated && userStats && section == 1) {
		return [NSString stringWithFormat: @"Stats for %@", [PhishTracksStats sharedInstance].username];
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(section == 0) {
		if (!isAuthenticated)
			return @"Register or sign-in on the settings tab for personalized stats.";
	}

	return nil;
}

@end
