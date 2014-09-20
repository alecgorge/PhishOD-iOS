//
//  GlobalActivityViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/30/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "GlobalActivityViewController.h"
#import "PhishTracksStats.h"
#import "PlayHistoryTableViewCell.h"
#import "ShowViewController.h"

@interface GlobalActivityViewController ()

@end

@implementation GlobalActivityViewController {
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
    [[PhishTracksStats sharedInstance] globalPlayHistoryWithLimit:100 offset:0
    success:^(NSArray *plays)
    {
        playEvents =  plays;
        self.title = @"Recent Activity";

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
		[cell setPlayEvent:play showUsername:YES];
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
