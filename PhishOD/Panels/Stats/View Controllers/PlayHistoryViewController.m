//
//  PlayHistoryViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/21/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PlayHistoryViewController.h"
#import "PhishTracksStats.h"
#import "PlayHistoryTableViewCell.h"
#import "ShowViewController.h"

@interface PlayHistoryViewController ()

@end

@implementation PlayHistoryViewController {
	NSArray *playEvents;
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		playEvents = nil;
    }
    return self;
}

- (void)refresh:(id)sender {
	if([PhishTracksStats sharedInstance].isAuthenticated) {
		[[PhishTracksStats sharedInstance] userPlayHistoryWithUserId:[PhishTracksStats sharedInstance].userId limit:100 offset:0
		success:^(NSArray *plays)
	    {
			playEvents =  plays;
			self.title = [NSString stringWithFormat:@"%@'s Play History", [PhishTracksStats sharedInstance].username];

			dispatch_async(dispatch_get_main_queue(), ^{
				[sender endRefreshing];
				[self.tableView reloadData];
			});
	    }
		failure:^(PhishTracksStatsError *error)
		{
//			[self.refreshControl endRefreshing];
            [sender endRefreshing];
			[FailureHandler showAlertWithStatsError:error];
		}];
	}
	else {
        [sender endRefreshing];
//		[super refresh:sender];
		[self.tableView reloadData];
	}
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (playEvents && section == 0) {
		return playEvents.count;
	}

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PlayHistoryCell";
    PlayHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if(cell == nil) {
		cell = [[PlayHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}

	if (indexPath.section == 0) {
		PhishTracksStatsPlayEvent *play = [playEvents objectAtIndex:indexPath.row];
		[cell setPlayEvent:play showUsername:NO];
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		PhishTracksStatsPlayEvent *play = [playEvents objectAtIndex:indexPath.row];
		ShowViewController *c = [[ShowViewController alloc] initWithShowDate:play.showDate];
		c.autoplayTrackId = play.trackId;
		c.autoplay = [PhishTracksStats sharedInstance].autoplayTracks;
		[self.navigationController pushViewController:c animated:YES];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (playEvents && section == 0) {
		return [NSString stringWithFormat:@"Last %ld plays", (long)playEvents.count];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) * 1.5;
}

@end
