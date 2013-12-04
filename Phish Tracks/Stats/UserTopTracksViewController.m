//
//  UserTopTracksViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/20/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "UserTopTracksViewController.h"
#import "RankingTableViewCell.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
		cell = [[RankingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}

	if (indexPath.section == 0) {
		PhishTracksStatsPlayEvent *play = [[queryResults getStatAtIndex:0].value objectAtIndex:indexPath.row];
		[cell setPlayEvent:play];
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		PhishTracksStatsPlayEvent *play = [[queryResults getStatAtIndex:0].value objectAtIndex:indexPath.row];
		ShowViewController *c = [[ShowViewController alloc] initWithShowDate:play.showDate];
		c.autoplayTrackId = play.trackId;
//		c.autoplay = YES;
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
	return tableView.rowHeight * 1.5;
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
