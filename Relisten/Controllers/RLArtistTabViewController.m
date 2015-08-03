//
//  RLAristTabViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLArtistTabViewController.h"

#import "NavigationControllerAutoShrinkerForNowPlaying.h"

#import "RLBrowseTableViewController.h"
#import "RLVenuesViewController.h"
#import "RLShowCollectionViewController.h"
#import "PHODDownloadTabTableViewController.h"
#import "PHODFavortiesViewController.h"

@interface RLArtistTabViewController ()

@property (nonatomic) NavigationControllerAutoShrinkerForNowPlaying *navDelegate;

@end

@implementation RLArtistTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.new;
	
    RLBrowseTableViewController *browse = RLBrowseTableViewController.new;
    UINavigationController *browseNav = [UINavigationController.alloc initWithRootViewController:browse];
    
    RLVenuesViewController *venues = RLVenuesViewController.new;
    UINavigationController *venuesNav = [UINavigationController.alloc initWithRootViewController:venues];

    RLShowCollectionViewController *top = RLShowCollectionViewController.alloc.initWithTopShows;
    UINavigationController *topNav = [UINavigationController.alloc initWithRootViewController:top];
    
    PHODDownloadTabTableViewController *dl = PHODDownloadTabTableViewController.new;
    UINavigationController *dlNav = [UINavigationController.alloc initWithRootViewController:dl];
    
    PHODFavortiesViewController *fav = PHODFavortiesViewController.new;
    UINavigationController *favNav = [UINavigationController.alloc initWithRootViewController:fav];

	browseNav.delegate = self.navDelegate;
    venuesNav.delegate = self.navDelegate;
    topNav.delegate = self.navDelegate;
    dlNav.delegate = self.navDelegate;
    favNav.delegate = self.navDelegate;
    
	self.viewControllers = @[
							 browseNav,
                             venuesNav,
                             topNav,
                             favNav,
                             dlNav
							 ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        self.selectedIndex = 4;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navDelegate addBarToViewController:self.viewControllers[0]];
    [self.navDelegate fixForViewController:self.viewControllers[0]];
}

@end
