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

@interface RLArtistTabViewController ()

@property (nonatomic) NavigationControllerAutoShrinkerForNowPlaying *navDelegate;

@end

@implementation RLArtistTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.new;
	
	RLBrowseTableViewController *browse = RLBrowseTableViewController.new;
	UINavigationController *browseNav = [UINavigationController.alloc initWithRootViewController:browse];
	
	browseNav.delegate = self.navDelegate;
	
	self.viewControllers = @[
							 browseNav
							 ];
}

@end
