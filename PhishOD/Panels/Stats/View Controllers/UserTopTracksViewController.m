//
//  UserTopTracksViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "UserTopTracksViewController.h"
#import "TrackRankingTableViewCell.h"
#import "PhishTracksStats.h"
#import "PhishTracksStatsStat.h"
#import "PhishTracksStatsPlayEvent.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"
#import "ShowViewController.h"
#import "StatsQueries.h"

@interface UserTopTracksViewController ()

@end

@implementation UserTopTracksViewController {
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		query = [StatsQueries predefinedStatQuery:kUserAllTimeTopTracks];
    }
    return self;
}

- (void)refresh:(id)sender {
	if([PhishTracksStats sharedInstance].isAuthenticated) {
		[[PhishTracksStats sharedInstance] userStatsWithUserId:[PhishTracksStats sharedInstance].userId statsQuery:query
		success:^(PhishTracksStatsQueryResults *result)
	    {
			queryResults = result;
			self.title = [NSString stringWithFormat:@"%@'s Top Tracks", queryResults.username];
			
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
	else {
        [sender endRefreshing];
		[self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[queryResults getStatAtIndex:0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RankingCell";
    RankingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if(cell == nil) {
		cell = [[TrackRankingTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
	}

    PhishTracksStatsPlayEvent *play = [[queryResults getStatAtIndex:0].value objectAtIndex:indexPath.row];
    [cell setPlayEvent:play];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		PhishTracksStatsPlayEvent *play = [[queryResults getStatAtIndex:0].value objectAtIndex:indexPath.row];
		ShowViewController *c = [[ShowViewController alloc] initWithShowDate:play.showDate];
		c.autoplayTrackId = play.trackId;
		c.autoplay = [PhishTracksStats sharedInstance].autoplayTracks;
		[self.navigationController pushViewController:c animated:YES];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (queryResults) {
		return [NSString stringWithFormat:@"Top %ld Tracks", (long)[[queryResults getStatAtIndex:0] count]];
	}
	else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) * 1.5;
}

@end
