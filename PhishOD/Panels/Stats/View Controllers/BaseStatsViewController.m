//
//  BaseStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "BaseStatsViewController.h"
#import "PhishTracksStatsPlayEvent.h"
#import "PhishTracksStats.h"

@interface BaseStatsViewController ()

@end

@implementation BaseStatsViewController {
}

- (id)initWithTitle:(NSString *)title andStatsQuery:(PhishTracksStatsQuery *)statsQuery
{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = title;
		query = statsQuery;
	}

	return self;
}

- (void)refresh:(id)sender {
	[[PhishTracksStats sharedInstance] globalStatsWithQuery:query
	success:^(PhishTracksStatsQueryResults *result)
	{
		queryResults = result;

		dispatch_async(dispatch_get_main_queue(), ^{
            [sender endRefreshing];
			[self.tableView reloadData];
		});
	}
	failure:^(PhishTracksStatsError *error)
	{
		[sender endRefreshing];
		[FailureHandler showAlertWithStatsError:error];
	}];
}

- (RankingTableViewCell *)cellForPlayEventWithReuseIdentifier:(NSString *)cellIdentifier
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!queryResults) return nil;

	if (queryResults.scalarStatCount > 0 && indexPath.section == 0) {
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
		static NSString *cellIdentifier = @"rankingCell";
		RankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if(cell == nil) {
			cell = [self cellForPlayEventWithReuseIdentifier:cellIdentifier];
		}
        
        NSInteger idx = queryResults.scalarStatCount > 0 ? (queryResults.scalarStatCount) : 0;
		PhishTracksStatsStat *stat = [queryResults getStatAtIndex:idx];
		PhishTracksStatsPlayEvent *play = [stat.value objectAtIndex:indexPath.row];
		[cell setPlayEvent:play];

		return cell;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (queryResults) {
		return (queryResults.scalarStatCount > 0 ? 1 : 0) + queryResults.nonScalarStatCount;  // All scalar stats are shown in the same section
	}

	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (queryResults) {
		if(queryResults.scalarStatCount > 0 && section == 0) {  // scalar stats section, if there are scalar stats
			return queryResults.scalarStatCount;
		}
		else {
            NSInteger idx = queryResults.scalarStatCount > 0 ? (queryResults.scalarStatCount) : 0;
			PhishTracksStatsStat *stat = [queryResults getStatAtIndex:idx];
			return [stat count];
		}
	}

	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(queryResults.scalarStatCount > 0 && indexPath.section == 0)
        return UITableViewAutomaticDimension;
	
    return (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) * 1.5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (queryResults) {
		if ((queryResults.scalarStatCount == 0 && section == 0) || (queryResults.scalarStatCount > 0 && section == 1)) {
			return [queryResults getStatAtIndex:queryResults.scalarStatCount].prettyName;
		}
	}

	return nil;
}

- (UIViewController *)viewControllerForPlay:(PhishTracksStatsPlayEvent *)play
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if((queryResults.scalarStatCount == 0 && indexPath.section == 0) || (queryResults.scalarStatCount > 0 && indexPath.section == 1)) {
        NSInteger idx = queryResults.scalarStatCount > 0 ? (queryResults.scalarStatCount) : 0;
		PhishTracksStatsStat *stat = [queryResults getStatAtIndex:idx];
		PhishTracksStatsPlayEvent *play = [stat.value objectAtIndex:indexPath.row];
        UIViewController *c = [self viewControllerForPlay:play];
		[self.navigationController pushViewController:c
											 animated:YES];
	}
}

@end
