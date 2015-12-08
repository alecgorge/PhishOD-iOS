//
//  RLSettingsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/16/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLSettingsViewController.h"

#import "RLArtistTabViewController.h"
#import "AppDelegate.h"
#import "IGAPIClient.h"

#import <SVWebViewController/SVWebViewController.h>
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>
#import <LastFm/LastFm.h>
#import <SVProgressHUD/SVProgressHUD.h>

NS_ENUM(NSInteger, IGAboutSections) {
    IGAboutSectionLastFM,
    IGAboutSectionDownloads,
    IGAboutSectionAppInfo,
    IGAboutSectionDeveloperInfo,
    IGAboutSectionAcknowledgements,
    IGAboutSectionCount,
};

NS_ENUM(NSInteger, IGAboutDownloads) {
    IGAboutDownloadsSize,
    IGAboutDownloadsDeleteAll,
    IGAboutDownloadsRowCount,
};

NS_ENUM(NSInteger, IGAboutLastFM) {
    IGAboutLastFMSignInOut,
    IGAboutLastFMRowCount
};

NS_ENUM(NSInteger, IGAboutAppInfoRows) {
    IGAboutAppInfoRowTwitter,
    IGAboutAppInfoRowLeaveReview,
    IGAboutAppInfoRowReportBug,
    IGAboutAppInfoRowRequestFeautres,
    IGAboutAppInfoRowCount
};

NS_ENUM(NSInteger, IGAboutDeveloperInfoRows) {
    IGAboutDeveloperInfoRowDeveloper,
    IGAboutDeveloperInfoRowGitHub,
    IGAboutDeveloperInfoRowWebVersion,
    //    IGAboutDeveloperInfoRowOtherApps,
    IGAboutDeveloperInfoRowCount
};

NS_ENUM(NSInteger, IGAboutAcknowledgementsRows) {
    IGAboutAcknowledgementsRowAcknowledgements,
    IGAboutAcknowledgementsRowSpecialThanks,
    IGAboutAcknowledgementsRowCount
};

@interface RLSettingsViewController ()

@end

@implementation RLSettingsViewController

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"cell"];
    
    [[LastFm sharedInstance] getSessionInfoWithSuccessHandler:^(NSDictionary *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failureHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    UIBarButtonItem *close = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(done)];
    
    self.navigationItem.rightBarButtonItem = close;
}

- (void)done {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return IGAboutSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == IGAboutSectionAppInfo) {
        return IGAboutAppInfoRowCount;
    }
    else if (section == IGAboutSectionLastFM) {
        return IGAboutLastFMRowCount;
    }
    else if (section == IGAboutSectionDeveloperInfo) {
        return IGAboutDeveloperInfoRowCount;
    }
    else if (section == IGAboutSectionAcknowledgements) {
        return IGAboutAcknowledgementsRowCount;
    }
    else if (section == IGAboutSectionDownloads) {
        return IGAboutDownloadsRowCount;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (section == IGAboutSectionAppInfo) {
        if (row == IGAboutAppInfoRowTwitter) {
            cell.textLabel.text = @"@relistenapp on Twitter";
        }
        else if (row == IGAboutAppInfoRowLeaveReview) {
            cell.textLabel.text = @"Rate Relisten on the App Store";
        }
        else if (row == IGAboutAppInfoRowReportBug) {
            cell.textLabel.text = @"Report a bug";
        }
        else if (row == IGAboutAppInfoRowRequestFeautres) {
            cell.textLabel.text = @"Request a feature";
        }
    }
    else if (section == IGAboutSectionDeveloperInfo) {
        if (row == IGAboutDeveloperInfoRowDeveloper) {
            cell.textLabel.text = @"Built by @alecgorge";
        }
        else if (row == IGAboutDeveloperInfoRowGitHub) {
            cell.textLabel.text = @"Source code on GitHub";
        }
        else if (row == IGAboutDeveloperInfoRowWebVersion) {
            cell.textLabel.text = @"Web version";
        }
        //        else if (row == IGAboutDeveloperInfoRowOtherApps) {
        //            cell.textLabel.text = @"Other music apps";
        //        }
    }
    else if (section == IGAboutSectionAcknowledgements) {
        if (row == IGAboutAcknowledgementsRowAcknowledgements) {
            cell.textLabel.text = @"3rd party acknowledgements";
        }
        else if(row == IGAboutAcknowledgementsRowSpecialThanks) {
            cell.textLabel.text = @"Special thanks to...";
        }
    }
    else if (section == IGAboutSectionLastFM) {
        if (row == IGAboutLastFMSignInOut) {
            if ([LastFm sharedInstance].username) {
                NSString *username = [LastFm sharedInstance].username;
                cell.textLabel.text = [NSString stringWithFormat:@"Sign out of %@", username];
            }
            else {
                cell.textLabel.text = @"Scrobble with Last.fm";
            }
        }
    }
    else if(indexPath.section == IGAboutSectionDownloads) {
        if(indexPath.row == IGAboutDownloadsSize) {
            NSString *bytes = [NSByteCountFormatter stringFromByteCount:[IGDownloadItem completeCachedSize]
                                                             countStyle:NSByteCountFormatterCountStyleFile];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ of downloaded music", bytes];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if(indexPath.row == IGAboutDownloadsDeleteAll) {
            cell.textLabel.text = @"Delete all downloaded tracks";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }

    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {
    if(section == IGAboutSectionAcknowledgements) {
        return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    
    return nil;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    UIViewController *vc;
    
    if (section == IGAboutSectionAppInfo) {
        if (row == IGAboutAppInfoRowTwitter) {
            NSURL *twitterUrl = [NSURL URLWithString:@"twitter://user?screen_name=relistenapp"];
            NSURL *tweetbotUrl = [NSURL URLWithString:@"tweetbot:///user_profile/relistenapp"];
            NSURL *safariUrl = [NSURL URLWithString:@"https://twitter.com/relistenapp"];
            
            NSArray *urls = @[tweetbotUrl, twitterUrl, safariUrl];
            
            for (NSURL *url in urls) {
                if([UIApplication.sharedApplication canOpenURL:url]) {
                    [UIApplication.sharedApplication openURL:url];
                    return;
                }
            }
        }
        else if (row == IGAboutAppInfoRowLeaveReview) {
            NSURL *itunesUrl = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id715886886"];
            [UIApplication.sharedApplication openURL:itunesUrl];
        }
        else if (row == IGAboutAppInfoRowReportBug) {
            vc = [[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishOD-iOS/issues"];
        }
        else if (row == IGAboutAppInfoRowRequestFeautres) {
            vc = [[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishOD-iOS/issues"];
        }
    }
    else if (section == IGAboutSectionDeveloperInfo) {
        if (row == IGAboutDeveloperInfoRowDeveloper) {
            vc = [[SVWebViewController alloc] initWithAddress:@"http://alecgorge.com"];
        }
        else if (row == IGAboutDeveloperInfoRowGitHub) {
            vc = [[SVWebViewController alloc] initWithAddress:@"https://github.com/alecgorge/PhishOD-iOS"];
        }
        else if (row == IGAboutDeveloperInfoRowWebVersion) {
            vc = [[SVWebViewController alloc] initWithAddress:@"http://relisten.net"];
        }
        //        else if (row == IGAboutDeveloperInfoRowOtherApps) {
        //
        //        }
    }
    else if (section == IGAboutSectionAcknowledgements) {
        if (row == IGAboutAcknowledgementsRowAcknowledgements) {
            vc = [VTAcknowledgementsViewController acknowledgementsViewController];
        }
        else if(row == IGAboutAcknowledgementsRowSpecialThanks) {
            vc = [[SVWebViewController alloc] initWithAddress:@"http://relisten.net/#about"];
        }
    }
    else if (section == IGAboutSectionLastFM) {
        if (row == IGAboutLastFMSignInOut) {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Sign into Last.FM"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Sign Out"
                                              otherButtonTitles:@"Sign In", nil];
            a.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [a show];
        }
    }
    else if(indexPath.section == IGAboutSectionDownloads) {
        if(indexPath.row == 0) {
        }
        else if(indexPath.row == 1) {
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Delete all downloaded tracks?"
                                                                       message:@"If you delete all your downloaded tracks, your phone will have more space but you won't be able to listen to music offline."
                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            [a addAction:[UIAlertAction actionWithTitle:@"Delete"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    [IGDownloadItem deleteEntireCache];
                                                    [self.tableView reloadData];
                                                }]];
            
            [a addAction:[UIAlertAction actionWithTitle:@"Don't Delete"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
            
            [self.navigationController presentViewController:a
                                                    animated:YES
                                                  completion:nil];
        }
    }
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
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


@end
