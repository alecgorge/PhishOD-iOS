//
//  SearchViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/16/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchDelegate.h"

@interface SearchViewController()

@property (nonatomic) UISearchDisplayController *con;
@property (nonatomic) SearchDelegate *conDel;

@end

@implementation SearchViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Search";
	
	[self createSearchBar];
}

- (void)dealloc {
	self.con = nil;
}

- (void)createSearchBar {
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
	
	self.con = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
												 contentsController:self];
	
	self.conDel = [[SearchDelegate alloc] initWithTableView:self.searchDisplayController.searchResultsTableView
									andNavigationController:self.navigationController];

	self.searchDisplayController.searchResultsDelegate = self.conDel;
	self.searchDisplayController.searchResultsDataSource = self.conDel;
	self.searchDisplayController.delegate = self.conDel;
	
	self.tableView.tableHeaderView = searchBar;
}

@end
