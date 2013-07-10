//
//  SettingsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SettingsViewController.h"
#import <LastFm.h>
#import <SVWebViewController.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)init {
    self = [super initWithStyle: UITableViewStyleGrouped];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 1) {
		return 3;
	}
	return [LastFm sharedInstance].username ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Last.FM";
	}
	else if(section == 1) {
		return @"Credits";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	if(indexPath.section == 0 && indexPath.row == 0) {
		if([LastFm sharedInstance].username) {
			cell.textLabel.text = [NSString stringWithFormat:@"Signed in as %@", [LastFm sharedInstance].username];
		}
		else {
			cell.textLabel.text = @"Scrobble with Last.FM account";
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if(indexPath.section == 0 && indexPath.row == 1) {
		cell.textLabel.text = @"View Last.FM profile";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if(indexPath.section == 1 && indexPath.row == 0) {
		cell.textLabel.text = @"Streaming provided by phishtracks.com!";
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if(indexPath.section == 1 && indexPath.row == 1) {
		cell.textLabel.text = @"App by Alec Gorge";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if(indexPath.section == 1 && indexPath.row == 2) {
		cell.textLabel.text = @"This app is open source on Github!";
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	if(indexPath.section == 0 && indexPath.row == 0) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Sign into Last.FM"
													message:nil
												   delegate:self
										  cancelButtonTitle:@"Sign Out"
										  otherButtonTitles:@"Sign In", nil];
		a.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
		[a show];
	}
	else if(indexPath.section == 0 && indexPath.row == 1) {
		NSString *add = [NSString stringWithFormat:@"http://last.fm/user/%@", [LastFm sharedInstance].username];
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:add]
											 animated:YES];
	}
	else if(indexPath.section == 1 && indexPath.row == 0) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"http://phishtracks.com/"]
											 animated:YES];
	}
	else if(indexPath.section == 1 && indexPath.row == 1) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"http://alecgorge.com/phish"]
											 animated:YES];
	}
	else if(indexPath.section == 1 && indexPath.row == 2) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishTracks-iOS"]
											 animated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Sign In"]) {
        UITextField *username = [alertView textFieldAtIndex:0];
        UITextField *password = [alertView textFieldAtIndex:1];
        [[LastFm sharedInstance] getSessionForUser:username.text
										  password:password.text
									successHandler:^(NSDictionary *result) {
										// Save the session into NSUserDefaults. It is loaded on app start up in AppDelegate.
										[[NSUserDefaults standardUserDefaults] setObject:result[@"key"] forKey:@"lastfm_session_key"];
										[[NSUserDefaults standardUserDefaults] setObject:result[@"name"] forKey:@"lastfm_username_key"];
										[[NSUserDefaults standardUserDefaults] synchronize];
										
										// Also set the session of the LastFm object
										[LastFm sharedInstance].session = result[@"key"];
										[LastFm sharedInstance].username = result[@"name"];
										[self.tableView reloadData];
									}
									failureHandler:^(NSError *error) {
										UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
																					message:[error localizedDescription]
																				   delegate:nil
																		  cancelButtonTitle:@"OK"
																		  otherButtonTitles:nil];
										[a show];
										[self.tableView reloadData];
									}];
    }
	else if([title isEqualToString:@"Sign Out"]) {
		[[LastFm sharedInstance] logout];
		[self.tableView reloadData];
	}
}

@end
