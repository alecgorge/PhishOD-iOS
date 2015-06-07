//
//  PHODMusicTabTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODMusicTabTableViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "TopRatedViewController.h"
#import "RandomShowViewController.h"
#import "PhishTracksStats.h"

#import "PHODLoadingTableViewCell.h"
#import "PHODCollectionTableViewCell.h"
#import "PHODCollectionCollectionViewCell.h"

#import "PHODCollectionProvider.h"

NS_ENUM(NSInteger, kPHODMusicTabSections) {
	kPHODMusicTabOnThisDaySection,
	kPHODMusicTabRecentSection,
	kPHODMusicTabPopularSection,
	kPHODMusicTabTopRatedSection,
	kPHODMusicTabSectionsCount
};

@interface PHODMusicTabTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic) PHODTopRatedCollectionProvider *topRatedProvider;
@property (nonatomic) PHODRecentCollectionProvider *recentProvider;
@property (nonatomic) PHODPopularCollectionProvider *popularProvider;
@property (nonatomic) PHODTodayCollectionProvider *todayProvider;

@end

@implementation PHODMusicTabTableViewController

- (instancetype)init {
	if (self = [super init]) {
		// set up tab bar
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Phish"
													  image:[UIImage imageNamed:@"glyphicons-18-music"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set up providers
	self.topRatedProvider = [PHODTopRatedCollectionProvider.alloc initWithContainingViewController:self
																						 inSection:kPHODMusicTabTopRatedSection];
	self.recentProvider = [PHODRecentCollectionProvider.alloc initWithContainingViewController:self
																					 inSection:kPHODMusicTabRecentSection];
	self.popularProvider = [PHODPopularCollectionProvider.alloc initWithContainingViewController:self
																					   inSection:kPHODMusicTabPopularSection];
	self.todayProvider = [PHODTodayCollectionProvider.alloc initWithContainingViewController:self
																				   inSection:kPHODMusicTabOnThisDaySection];
	
	// set up table view
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 150.0f;

	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODLoadingTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"loadingCell"];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODCollectionTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"collectionCell"];
	
	// set up view controller things
	self.title = @"PhishOD";
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
																						 target:self
																						 action:@selector(startSearch)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kPHODMusicTabRecentSection]
				  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kPHODMusicTabSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == kPHODMusicTabRecentSection) {
		return 1;
	}
	else if(section == kPHODMusicTabTopRatedSection) {
		return 1;
	}
	else if(section == kPHODMusicTabPopularSection) {
		return 1;
	}
	else if(section == kPHODMusicTabOnThisDaySection) {
		return 1;
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == kPHODMusicTabRecentSection) {
		return @"Recently Played";
	}
	else if(section == kPHODMusicTabTopRatedSection) {
		return @"Top Rated on Phish.net";
	}
	else if(section == kPHODMusicTabPopularSection) {
		return @"Popular Shows This Week";
	}
	else if(section == kPHODMusicTabOnThisDaySection) {
		return @"On This Day in Phish-tory";
	}
	
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
	CGFloat barHeight = 35.0f;
	CGFloat buttonWidth = 50.0f;
	CGFloat padding = 15.0f;
	
	NSString *title = [tableView.dataSource tableView:tableView
							  titleForHeaderInSection:section];
	
	UILabel *titleView = [UILabel.alloc initWithFrame:CGRectMake(padding,
																 0,
																 tableView.bounds.size.width - padding * 2 - buttonWidth,
																 barHeight)];
	titleView.text = title;
	titleView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	
	UIView *v = [UIView.alloc initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, barHeight)];
	v.backgroundColor = UIColor.whiteColor;
	
	UIView *line = [UIView.alloc initWithFrame:CGRectMake(0, barHeight - 1, tableView.bounds.size.width, 1)];
	line.backgroundColor = [UIColor colorWithWhite:0.917 alpha:1.000];
	
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
//	[v addSubview:line];
	[v addSubview:titleView];
	
	if(section == kPHODMusicTabTopRatedSection) {
		UIButton *more = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		
		[more setTitle:@"more"
			  forState:UIControlStateNormal];
		
		more.tag = section;
		
		[more addTarget:self
				 action:@selector(viewMoreForSectionButton:)
	   forControlEvents:UIControlEventTouchUpInside];
		
		more.frame = CGRectMake(tableView.bounds.size.width - padding - buttonWidth,
								0,
								buttonWidth,
								barHeight);
		
		more.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[v addSubview:more];
	}
	
	return v;
}

- (void)viewMoreForSectionButton:(UIButton *)sender {
	if(sender.tag == kPHODMusicTabTopRatedSection) {
		[self.navigationController pushViewController:[TopRatedViewController.alloc initWithTopShows:self.topRatedProvider.topRatedShows]
											 animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
	return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	PHODCollectionProvider *p = nil;
    
	if(indexPath.section == kPHODMusicTabRecentSection) {
		p = self.recentProvider;
	}
	else if(indexPath.section == kPHODMusicTabTopRatedSection) {
		p = self.topRatedProvider;
	}
	else if(indexPath.section == kPHODMusicTabOnThisDaySection) {
		p = self.todayProvider;
	}
	else if(indexPath.section == kPHODMusicTabPopularSection) {
		p = self.popularProvider;
	}
	
	if (p.isDoneLoadingData) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"
											   forIndexPath:indexPath];
		
		PHODCollectionTableViewCell *c = (PHODCollectionTableViewCell *)cell;
		
		c.uiCollectionView.delegate = p;
		c.uiCollectionView.dataSource = p;
		c.uiCollectionView.emptyDataSetSource = self;
		c.uiCollectionView.emptyDataSetDelegate = self;
		
		[c.uiCollectionView reloadData];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"
											   forIndexPath:indexPath];
		
		PHODLoadingTableViewCell *c = (PHODLoadingTableViewCell *)cell;
		[c.uiActivityIndicator startAnimating];
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PHODCollectionProvider *p = nil;
	
	if(indexPath.section == kPHODMusicTabRecentSection) {
		p = self.recentProvider;
	}
	else if(indexPath.section == kPHODMusicTabTopRatedSection) {
		p = self.topRatedProvider;
	}
	else if(indexPath.section == kPHODMusicTabOnThisDaySection) {
		p = self.todayProvider;
	}
	else if(indexPath.section == kPHODMusicTabPopularSection) {
		p = self.popularProvider;
	}
	
	if(p.isDoneLoadingData) {
		return [PHODCollectionCollectionViewCell rowHeight];
	}
	
	return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == kPHODMusicTabRecentSection) {
		
	}
	else if(indexPath.section == kPHODMusicTabTopRatedSection) {
		
	}
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
	return [NSAttributedString.alloc initWithString:@"You haven't listened to any shows yet :("];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
	return [NSAttributedString.alloc initWithString:@"Listen to a random show »"];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
	[self.navigationController pushViewController:RandomShowViewController.new
										 animated:YES];
}

@end
