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
    
    RLVenuesViewController *venues = RLVenuesViewController.new;

    RLShowCollectionViewController *top = RLShowCollectionViewController.alloc.initWithTopShows;
    
    PHODDownloadTabTableViewController *dl = PHODDownloadTabTableViewController.new;
    
    PHODFavortiesViewController *fav = PHODFavortiesViewController.new;
    
    self.navigationController.delegate = self.navDelegate;
    
	self.viewControllers = @[
							 browse,
                             venues,
                             top,
                             fav,
                             dl
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
    
    [self.navDelegate addBarToViewController];
    [self.navDelegate fixForViewController:self.viewControllers[0]];
}

@end
