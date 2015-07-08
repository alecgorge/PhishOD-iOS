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
    
	browseNav.delegate = self.navDelegate;
    venuesNav.delegate = self.navDelegate;
    
	self.viewControllers = @[
							 browseNav,
                             venuesNav
							 ];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navDelegate addBarToViewController:self.viewControllers[0]];
    [self.navDelegate fixForViewController:self.viewControllers[0]];
}

@end
