//
//  SettingsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SettingsViewController.h"
#import "StatsNewSessionViewController.h"
#import "StatsEditSessionViewController.h"
#import "StatsRegistrationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <LastFm.h>
#import <SVWebViewController.h>
#import "PhishTracksStats.h"
#import "LivePhishAuth.h"

#define kAlertLastFm 0
//#define kAlertPhishTracksStats 1

typedef NS_ENUM(NSInteger, PhishODSettingsSections) {
	PhishODSettingsSectionLastFM,
	PhishODSettingsSectionLivePhish,
	PhishODSettingsSectionStats,
	PhishODSettingsSectionCredits,
	PhishODSettingsSectionFeedback,
	PhishODSettingsSectionCount,
};

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

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Settings";
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PhishODSettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == PhishODSettingsSectionLastFM) { // Last.fm
		return [LastFm sharedInstance].username ? 2 : 1;
	}
	else if(section == PhishODSettingsSectionStats) {  // stats
		if([PhishTracksStats sharedInstance].isAuthenticated)
			return 1;  // view account
		else
			return 2;  // sign in, sign up

	}
	else if(section == PhishODSettingsSectionLivePhish) {
		if(LivePhishAuth.sharedInstance.hasCredentials) {
			return 2;
		}
		else {
			return 1;
		}
	}
	else if(section == PhishODSettingsSectionCredits) {  // credits
		return 6;
	}
	else if(section == PhishODSettingsSectionFeedback) {  // feedback
		return 2;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == PhishODSettingsSectionLastFM) {
		return @"Last.FM";
	}
	else if(section == PhishODSettingsSectionLivePhish) {
		return @"LivePhish.com";
	}
	else if(section == PhishODSettingsSectionStats) {
		return @"Stats & Favorites";
	}
	else if(section == PhishODSettingsSectionCredits) {
		return @"Credits";
	}
	else if(section == PhishODSettingsSectionFeedback) {
		return @"Bugs & Features";
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
	
	if(indexPath.section == PhishODSettingsSectionLastFM && indexPath.row == 0) {
		if([LastFm sharedInstance].username) {
			cell.textLabel.text = [NSString stringWithFormat:@"Signed in as %@", [LastFm sharedInstance].username];
		}
		else {
			cell.textLabel.text = @"Scrobble with Last.FM account";
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionLastFM && indexPath.row == 1) {
		cell.textLabel.text = @"View Last.FM profile";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionLivePhish) {
		if(LivePhishAuth.sharedInstance.hasCredentials) {
			if(indexPath.row == 0) {
				cell.textLabel.text = [NSString stringWithFormat:@"Signed in as: %@", LivePhishAuth.sharedInstance.username];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			else if(indexPath.row == 1) {
				cell.textLabel.text = @"Sign out";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		else {
			cell.textLabel.text = @"Sign in";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(indexPath.section == PhishODSettingsSectionStats) {
		if ([PhishTracksStats sharedInstance].isAuthenticated) {
			if (indexPath.row == 0) {
				cell.textLabel.text = [NSString stringWithFormat:@"Signed in as %@", [PhishTracksStats sharedInstance].username];
			}
		}
		else {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"Sign in";
			}
			else {
				cell.textLabel.text = @"Register";
			}
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionStats && indexPath.row == 1) {
		cell.textLabel.text = @"Register";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;		
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 0) {
		cell.textLabel.text = @"Streaming by phish.in";
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 1) {
		cell.textLabel.text = @"App by Alec Gorge";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 2) {
		cell.textLabel.text = @"Contribute on Github";
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 3) {
		cell.textLabel.text = @"Some data from phish.net";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 4) {
		cell.textLabel.text = @"Thanks Mockingbird Foundation";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 5) {
		cell.textLabel.text = @"Stats by phishtrackstats.com";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionFeedback && indexPath.row == 0) {
		cell.textLabel.text = @"Report a bug";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == PhishODSettingsSectionFeedback && indexPath.row == 1) {
		cell.textLabel.text = @"Request a feature";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	if(indexPath.section == PhishODSettingsSectionLastFM && indexPath.row == 0) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Sign into Last.FM"
													message:nil
												   delegate:self
										  cancelButtonTitle:@"Sign Out"
										  otherButtonTitles:@"Sign In", nil];
		a.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
		a.tag = kAlertLastFm;
		[a show];
	}
	else if(indexPath.section == PhishODSettingsSectionLastFM && indexPath.row == 1) {
		NSString *add = [NSString stringWithFormat:@"http://last.fm/user/%@", [LastFm sharedInstance].username];
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:add]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionLivePhish) {
		if(LivePhishAuth.sharedInstance.hasCredentials) {
			if(indexPath.row == 0) {
				
			}
			else if(indexPath.row == 1) {
				[LivePhishAuth.sharedInstance signOut];
				[self.tableView reloadData];
			}
		}
		else {
			[LivePhishAuth.sharedInstance ensureSignedInFrom:self
													 success:^{
														 [self.tableView reloadData];
													 }];
		}
	}
	else if(indexPath.section == PhishODSettingsSectionStats && indexPath.row == 0) {
		if ([PhishTracksStats sharedInstance].isAuthenticated) {
			[self.navigationController pushViewController:[[StatsEditSessionViewController alloc] init] animated:YES];
		}
		else {
			[self.navigationController pushViewController:[[StatsNewSessionViewController alloc] init] animated:YES];
			[self.tableView reloadData];
		}
	}
	else if(indexPath.section == PhishODSettingsSectionStats && indexPath.row == 1) {
		[self.navigationController pushViewController:[[StatsRegistrationViewController alloc] init] animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 0) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"http://phish.in/"]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 1) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"http://alecgorge.com/phish"]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 2) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishOD-iOS"]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 3) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://phish.net"]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 4) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://mbird.org"]
											 animated:YES];
	}
	else if(indexPath.section == PhishODSettingsSectionCredits && indexPath.row == 5) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://www.phishtrackstats.com"]
											 animated:YES];
	}
	else if((indexPath.section == PhishODSettingsSectionFeedback && indexPath.row == 0) || (indexPath.section == PhishODSettingsSectionFeedback && indexPath.row == 1)) {
		[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishOD-iOS/issues"]
											 animated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == kAlertLastFm) {
		NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
		if([title isEqualToString:@"Sign In"]) {
			UITextField *username = [alertView textFieldAtIndex:0];
			UITextField *password = [alertView textFieldAtIndex:1];
			[SVProgressHUD show];
			[[LastFm sharedInstance] getSessionForUser:username.text
											  password:password.text
										successHandler:^(NSDictionary *result) {
											[SVProgressHUD dismiss];
											// Save the session into NSUserDefaults. It is loaded on app start up in AppDelegate.
											[[NSUserDefaults standardUserDefaults] setObject:result[@"key"] forKey:@"lastfm_session_key"];
											[[NSUserDefaults standardUserDefaults] setObject:result[@"name"] forKey:@"lastfm_username_key"];
											[[NSUserDefaults standardUserDefaults] synchronize];
											
											// Also set the session of the LastFm object
											[LastFm sharedInstance].session = result[@"key"];
											[LastFm sharedInstance].username = result[@"name"];
											
											dispatch_async(dispatch_get_main_queue(), ^{
												[self.tableView reloadData];
											});
										}
										failureHandler:^(NSError *error) {
                                            [SVProgressHUD dismiss];
											UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
																						message:[error localizedDescription]
																					   delegate:nil
																			  cancelButtonTitle:@"OK"
																			  otherButtonTitles:nil];
											[a show];

											dispatch_async(dispatch_get_main_queue(), ^{
												[self.tableView reloadData];
											});
										}];
		}
		else if([title isEqualToString:@"Sign Out"]) {
			[[LastFm sharedInstance] logout];
			[self.tableView reloadData];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to reload selected cell
}

@end
