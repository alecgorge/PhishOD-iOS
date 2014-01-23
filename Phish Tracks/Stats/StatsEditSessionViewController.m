//
//  StatsEditSessionViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/17/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <SVWebViewController.h>
#import "StatsEditSessionViewController.h"
#import "PhishTracksStats.h"

@interface StatsEditSessionViewController ()

@end

@implementation StatsEditSessionViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
		self.title = @"Account";
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 1;
	else
		return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	if(indexPath.section == 0 && indexPath.row == 0) {
		cell.textLabel.text = @"Edit account";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else {
		cell.textLabel.text = @"Sign out";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if(indexPath.section == 0 && indexPath.row == 0) {
		NSString *add = [NSString stringWithFormat:@"https://www.phishtrackstats.com/users/edit"];
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:add] animated:YES];
	}
	else {
		[[PhishTracksStats sharedInstance] clearLocalSession];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

@end
