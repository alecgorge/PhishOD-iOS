//
//  PHODNewHomeViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 11/12/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODNewHomeViewController.h"

#import "AppDelegate.h"
#import "ShowViewController.h"
#import "YearsViewController.h"
#import "SongsViewController.h"
#import "ToursViewController.h"
#import "TopRatedViewController.h"
#import "PhishTracksStatsViewController.h"
#import "SettingsViewController.h"
#import "VenuesViewController.h"
#import "SearchViewController.h"
#import "RandomShowViewController.h"
#import "SearchDelegate.h"
#import "FavoritesViewController.h"
#import "GlobalActivityViewController.h"
#import "CuratedPlaylistsViewController.h"
#import "PhishNetAuth.h"

#import "PhishNetBlogViewController.h"
#import "PhishNetNewsViewController.h"
#import "PhishNetShowsViewController.h"

#import "PhishinDownloadedShowsViewController.h"
#import "DownloadQueueViewController.h"

#import <OHActionSheet/OHActionSheet.h>

@interface PHODNewHomeViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *uiButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonEverything;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonDiscover;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonPhishNet;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonStats;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonNowPlaying;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonDownloads;

@property (nonatomic) NSArray *buttons;
@property (nonatomic) NSArray *menus;
@property (nonatomic) NSArray *submenus;

@property (nonatomic) NSInteger screenWidth;

@end

@implementation PHODNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttons = @[self.uiButtonEverything,
                     self.uiButtonDiscover,
                     self.uiButtonPhishNet,
                     self.uiButtonStats
                     ];
    
    self.menus = @[@[@"years", @"songs", @"venues", @"tours"],
                   @[@"top", @"random", @"playlists"],
                   @[@"my shows", @"blog", @"news"],
                   @[@"stats", @"favorites", @"recent"]
                   ];
    
    [self buildSubmenus];
    
}

- (void)viewWillAppear:(BOOL)animated {
    PhishinShow *show = [AppDelegate sharedDelegate].currentlyPlayingShow;
    
    if (!show) {
        self.uiButtonNowPlaying.hidden = YES;
    }
    else {
        self.uiButtonNowPlaying.hidden = NO;
        [self.uiButtonNowPlaying setTitle:[NSString stringWithFormat:@"%@ ›", show.date]
                                 forState:UIControlStateNormal];
    }

    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
}

- (void)buildSubmenus {
    NSMutableArray *subs = NSMutableArray.array;
    NSInteger width = UIScreen.mainScreen.bounds.size.width;
    
    self.screenWidth = width;
  
    for (NSInteger i = 0; i < self.menus.count; i++) {
        NSArray *submenu = self.menus[i];
        UIButton *button  = self.buttons[i];
        
        UIView *container = [UIView.alloc initWithFrame:CGRectMake(-width * 2,
                                                                   button.frame.origin.y,
                                                                   width * 2,
                                                                   button.frame.size.height)];
        
        container.backgroundColor = COLOR_PHISH_GREEN;
        
        NSInteger buttonWidth = width / submenu.count;
        for(NSInteger j = 0; j < submenu.count; j++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(width + j * buttonWidth,
                                 0,
                                 buttonWidth,
                                 button.frame.size.height);
            b.backgroundColor = COLOR_PHISH_GREEN;
            b.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            
            b.tag = (i << 16) | (j & 0xFFFF);
            
            [b setTitle:submenu[j]
               forState:UIControlStateNormal];
            
            [b setTitleColor:COLOR_PHISH_WHITE
                    forState:UIControlStateNormal];
            
            [b addTarget:self
                  action:@selector(submenuItemTapped:)
        forControlEvents:UIControlEventTouchUpInside];
            
            [container addSubview:b];
        }
        
        container.tag = button.tag = 1654 + i;
        
        [subs addObject:container];
        [self.uiButtonContainer addSubview:container];
        
        [button addTarget:self
                   action:@selector(menuItemTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.submenus = subs;
}

- (IBAction)downloadedShows:(id)sender {
    [OHActionSheet showFromView:self.uiButtonDownloads
                          title:@"Downloads"
              cancelButtonTitle:@"Cancel"
         destructiveButtonTitle:nil
              otherButtonTitles:@[@"Download Queue", @"Downloaded Shows"]
                     completion:^(OHActionSheet *sheet, NSInteger buttonIndex) {
                         if(buttonIndex == 0) {
                             [self pushViewController:DownloadQueueViewController.alloc.init];
                         }
                         else if(buttonIndex == 1) {
                             [self pushViewController:PhishinDownloadedShowsViewController.alloc.init];
                         }
                     }];
}

- (IBAction)settingsTapped:(id)sender {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)submenuItemTapped:(UIButton *)btn {
    NSInteger section = btn.tag >> 16;
    NSInteger row = btn.tag & 0xFFFF;
    
    if(section == 0 && row == 0) {
        [self pushViewController:[[YearsViewController alloc] init]];
    }
    else if(section == 0 && row == 1) {
        [self pushViewController:[[SongsViewController alloc] init]];
    }
    else if(section == 0 && row == 2) {
        [self pushViewController:[[VenuesViewController alloc] init]];
    }
    else if(section == 0 && row == 3) {
        [self pushViewController:[[ToursViewController alloc] init]];
    }
    else if(section == 1 && row == 0) {
        [self pushViewController:[[TopRatedViewController alloc] init]];
    }
    else if(section == 1 && row == 1) {
        [self pushViewController:[[RandomShowViewController alloc] init]];
    }
    else if(section == 1 && row == 2) {
        [self pushViewController:CuratedPlaylistsViewController.alloc.init];
    }
    else if(section == 3 && row == 0) {
        [self pushViewController:[[PhishTracksStatsViewController alloc] init]];
    }
    else if(section == 3 && row == 1) {
        [self pushViewController:[[FavoritesViewController alloc] init]];
    }
    else if(section == 3 && row == 2) {
        [self pushViewController:[[GlobalActivityViewController alloc] init]];
    }
    else if(section == 2 && row == 1) {
        [self pushViewController:PhishNetBlogViewController.alloc.init];
    }
    else if(section == 3 && row == 2) {
        [self pushViewController:PhishNetNewsViewController.alloc.init];
    }
    else if(section == 3 && row == 0) {
        [PhishNetAuth.sharedInstance ensureSignedInFrom:self
                                                success:^{
                                                    [self pushViewController:PhishNetShowsViewController.alloc.init];
                                                }];
    }
}

- (void)menuItemTapped:(UIButton *)btn {
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         for (UIView *container in self.submenus) {
                             CGRect f = container.frame;
                             if(container.tag == btn.tag) {
                                 f.origin.x = -self.screenWidth;
                             }
                             else {
                                 f.origin.x = -self.screenWidth * 2;
                             }
                             container.frame = f;
                         }
                         
                         for (UIButton *b in self.buttons) {
                             CGRect f = b.frame;
                             if(b != btn) {
                                 f.origin.x = 0;
                             }
                             else {
                                 f.origin.x = self.screenWidth;
                             }
                             b.frame = f;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)tappedNowPlaying:(id)sender {
    [self pushViewController:[ShowViewController.alloc initWithShow:AppDelegate.sharedDelegate.currentlyPlayingShow]];
}

- (void)pushViewController:(UIViewController*)vc {
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
