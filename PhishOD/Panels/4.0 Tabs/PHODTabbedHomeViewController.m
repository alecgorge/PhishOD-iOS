//
//  PHODTabbedHomeViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODTabbedHomeViewController.h"

#import "NavigationControllerAutoShrinkerForNowPlaying.h"

#import "PHODMusicTabTableViewController.h"
#import "PHODBrowseTableViewController.h"
#import "PHODPhishNetTableViewController.h"
#import "PHODDownloadTabTableViewController.h"
#import "PhishTracksStatsViewController.h"

@interface PHODTabbedHomeViewController ()

@property (nonatomic) NavigationControllerAutoShrinkerForNowPlaying *navDelegate;

@end

@implementation PHODTabbedHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.alloc.init;
	
	PHODMusicTabTableViewController *music = PHODMusicTabTableViewController.new;
	UINavigationController *musicNav = [UINavigationController.alloc initWithRootViewController:music];
	
	PHODBrowseTableViewController *browse = PHODBrowseTableViewController.new;
	UINavigationController *browseNav = [UINavigationController.alloc initWithRootViewController:browse];
	
	PHODPhishNetTableViewController *ph = PHODPhishNetTableViewController.new;
	UINavigationController *phNav = [UINavigationController.alloc initWithRootViewController:ph];
	
	PHODDownloadTabTableViewController *dl = PHODDownloadTabTableViewController.new;
	UINavigationController *dlNav = [UINavigationController.alloc initWithRootViewController:dl];
	
	PhishTracksStatsViewController *stats = PhishTracksStatsViewController.new;
	UINavigationController *statsNav = [UINavigationController.alloc initWithRootViewController:stats];
	
	musicNav.delegate = self.navDelegate;
	browseNav.delegate = self.navDelegate;
	phNav.delegate = self.navDelegate;
	dlNav.delegate = self.navDelegate;

	self.viewControllers = @[
							 musicNav,
							 browseNav,
							 phNav,
							 dlNav,
							 statsNav
							 ];
	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
