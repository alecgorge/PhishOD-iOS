//
//  GlobalStatsViewController.m
//  Phish Tracks
//
//  This controller assumes the stats query has n>0 scalar stats followed by a ranking stat
//
//  Created by Alec Gorge on 7/27/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "GlobalStatsViewController.h"
#import "PhishTracksStats.h"
#import "PhishTracksStatsPlayEvent.h"
#import "ShowViewController.h"
#import "RankingTableViewCell.h"

@interface GlobalStatsViewController ()

@end

@implementation GlobalStatsViewController

- (id)initWithTitle:(NSString *)title andStatsQuery:(PhishTracksStatsQuery *)statsQuery
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = title;
		query = statsQuery;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
//	self.title = @"Global Stats";
}

- (void)refresh:(id)sender {
	if([PhishTracksStats sharedInstance].isAuthenticated) {
		[[PhishTracksStats sharedInstance] globalStatsWithQuery:query
		success:^(PhishTracksStatsQueryResults *result)
	    {
			queryResults = result;

			dispatch_async(dispatch_get_main_queue(), ^{
				[super refresh:sender];
				[self.tableView reloadData];
			});
	    }
		failure:^(NSError *error)
		{
			NSLog(@"%@", error);
			REQUEST_FAILED(self.tableView);
		}];
	}
	else {
		[super refresh:sender];
		[self.tableView reloadData];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (queryResults) {
		return queryResults.nonScalarStatCount + 1;  // All scalar stats are in same group
	}

	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (queryResults) {
		if(section == 0) {  // scalar stats section, if there are scalar stats
			return queryResults.scalarStatCount;
		}
		else {
			PhishTracksStatsStat *stat = [queryResults getStatAtIndex:(queryResults.scalarStatCount - 1 + section)];
			return [stat count];
		}
	}

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!queryResults) return nil;

	if (indexPath.section == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1Cell"];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"value1Cell"];
		}

		PhishTracksStatsStat *stat = [queryResults getStatAtIndex:indexPath.row];

		cell.textLabel.text = stat.prettyName;
		cell.detailTextLabel.text = [stat valueAsString];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		return cell;
	}
	else {
		static NSString *cellIdentifier = @"RankingCell";
		RankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell == nil) {
			cell = [[RankingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		}

		PhishTracksStatsStat *stat = [queryResults getStatAtIndex:(queryResults.scalarStatCount - 1 + indexPath.section)];
		PhishTracksStatsPlayEvent *play = [stat.value objectAtIndex:indexPath.row];
		[cell setPlayEvent:play];

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
//	if(indexPath.section == 1) {
//		PhishTracksStatsPlayEvent *item = self.history[indexPath.row];
//		PhishinShow *show = [[PhishinShow alloc] init];
//		show.date = item.showDate;
//		[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
//											 animated:YES];
//	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) {
		return tableView.rowHeight * 1.3;
	}

	return UITableViewAutomaticDimension;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (queryResults) {
		if (section == 1) {
			return [NSString stringWithFormat:@"Top %ld Tracks", (long)[[queryResults getStatAtIndex:queryResults.scalarStatCount] count]];
		}
	}

	return nil;
}

@end
