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

@implementation RLArtistTabViewController {
    NSArray *hConstraints;
    NSArray *vConstraints;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navDelegate = NavigationControllerAutoShrinkerForNowPlaying.new;
	
    RLBrowseTableViewController *browse = RLBrowseTableViewController.new;
    UINavigationController *browseNC = [[UINavigationController alloc] initWithRootViewController:browse];
    
    RLVenuesViewController *venues = RLVenuesViewController.new;
    UINavigationController *venuesNC = [[UINavigationController alloc] initWithRootViewController:venues];

    RLShowCollectionViewController *top = RLShowCollectionViewController.alloc.initWithTopShows;
    UINavigationController *topNC = [[UINavigationController alloc] initWithRootViewController:top];
    
    PHODDownloadTabTableViewController *dl = PHODDownloadTabTableViewController.new;
    UINavigationController *dlNC = [[UINavigationController alloc] initWithRootViewController:dl];
    
    PHODFavortiesViewController *fav = PHODFavortiesViewController.new;
    UINavigationController *favNC = [[UINavigationController alloc] initWithRootViewController:fav];
    
    browseNC.delegate = self.navDelegate;
    venuesNC.delegate = self.navDelegate;
    topNC.delegate = self.navDelegate;
    dlNC.delegate = self.navDelegate;
    favNC.delegate = self.navDelegate;
    
	self.viewControllers = @[
							 browseNC,
                             venuesNC,
                             topNC,
                             favNC,
                             dlNC
							 ];
    
    self.edgeView = [[UIView alloc] init];
    self.edgeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.edgeView];
    self.edgeView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.005];
    NSDictionary *bindings = @{@"edgeView": self.edgeView};
    NSLayoutFormatOptions options = NSLayoutFormatAlignAllLeft;
    hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[edgeView(5)]" options:options metrics:nil views:bindings];
    vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[edgeView]-0-|" options:options metrics:nil views:bindings];
    [self.view addConstraints:hConstraints];
    [self.view addConstraints:vConstraints];
}

- (void)enableEdgeGesture {
    [self.view addSubview:self.edgeView];
    [self.view addConstraints:hConstraints];
    [self.view addConstraints:vConstraints];
}

- (void)disableEdgeGesture {
    [self.edgeView removeFromSuperview];
    [self.view removeConstraints:hConstraints];
    [self.view removeConstraints:vConstraints];
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
    [self.navDelegate fixForViewController:self.viewControllers[0] force:true];
}

@end
