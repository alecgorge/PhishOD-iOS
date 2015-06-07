//
//  TopRatedCollectionProvider.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODCollectionProvider.h"

#import "PHODCollectionCollectionViewCell.h"

#import "PHODHistory.h"
#import "ShowViewController.h"
#import "PhishNetAPI.h"
#import "PhishNetAuth.h"

#import "PhishTracksStats.h"
#import "PhishTracksStatsPlayEvent.h"

@implementation PHODCollectionProvider

- (instancetype)initWithContainingViewController:(UITableViewController *)vc
									   inSection:(NSInteger)section {
	if (self = [super init]) {
		self.viewController = vc;
		self.section = section;
		[self loadData];
	}
	
	return self;
}

- (void)loadData {
	NSAssert(YES, @"this needs to be overriden!");
}

-(id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	NSAssert(YES, @"this needs to be overriden!");
	return nil;
}

-(void)selectedCollectionAtIndex:(NSInteger)idx {
	NSAssert(YES, @"this needs to be overriden!");
}

- (void)finishedLoadingData {
	[self.viewController.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.section]
								 withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	if(!self.isDoneLoadingData) {
		return 0;
	}
	
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return [self collectionCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	PHODCollectionCollectionViewCell *cell = (PHODCollectionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PHODCollectionCell"
																							   forIndexPath:indexPath];
	
	[cell updateWithCollection:[self collectionForIndex:indexPath.item]];
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return [PHODCollectionCollectionViewCell itemSize];
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[collectionView deselectItemAtIndexPath:indexPath
								   animated:YES];
	
	[self selectedCollectionAtIndex:indexPath.item];
}

@end

@implementation PHODTopRatedCollectionProvider

- (void)loadData {
	[PhishNetAPI.sharedAPI topRatedShowsWithSuccess:^(NSArray *to) {
		self.topRatedShows = to;
		
		[self finishedLoadingData];
	}
											failure:REQUEST_FAILED(self.viewController.tableView)];
}

- (BOOL)isDoneLoadingData {
	return self.topRatedShows != nil;
}

- (NSInteger)collectionCount {
	return self.topRatedShows.count;
}

- (id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	return self.topRatedShows[idx];
}

-(void)selectedCollectionAtIndex:(NSInteger)idx {
	PhishNetTopShow *topShow = self.topRatedShows[idx];
	PhishinShow *show = PhishinShow.new;
	show.date = topShow.showDate;
	
	[self.viewController.navigationController pushViewController:[ShowViewController.alloc initWithShow:show]
														animated:YES];
}

@end

@implementation PHODRecentCollectionProvider

- (BOOL)isDoneLoadingData {
	return YES;
}

- (void)loadData {
	[self finishedLoadingData];
}

- (id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	return PHODHistory.sharedInstance.history[idx];
}

- (NSInteger)collectionCount {
	return PHODHistory.sharedInstance.history.count;
}

- (void)selectedCollectionAtIndex:(NSInteger)idx {
	PhishinShow *show = PHODHistory.sharedInstance.history[idx];
	
	[self.viewController.navigationController pushViewController:[ShowViewController.alloc initWithShow:show]
														animated:YES];
}

@end

@implementation PHODTodayCollectionProvider

- (void)loadData {
	[PhishinAPI.sharedAPI onThisDay:^(PhishinYear *year) {
		self.todaysShows = year.shows;
		[self finishedLoadingData];
	}
							failure:REQUEST_FAILED(self.viewController.tableView)];
}

- (BOOL)isDoneLoadingData {
	return self.todaysShows != nil;
}

- (NSInteger)collectionCount {
	return self.todaysShows.count;
}

- (id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	return self.todaysShows[idx];
}

-(void)selectedCollectionAtIndex:(NSInteger)idx {
	PhishinShow *show = self.todaysShows[idx];
	
	[self.viewController.navigationController pushViewController:[ShowViewController.alloc initWithShow:show]
														animated:YES];
}

@end

@implementation PHODPopularCollectionProvider

- (void)loadData {
	PhishTracksStatsQuery *q = [PhishTracksStatsQuery.alloc initWithEntity:@"shows"
																 timeframe:@"this_week"];
	
	[q addStatWithName:@"play_count_ranking"];
	
	[PhishTracksStats.sharedInstance globalStatsWithQuery:q
												  success:^(PhishTracksStatsQueryResults *r) {
													  self.popularShows = [r getStatAtIndex:0].value;
													  [self finishedLoadingData];
												  }
												  failure:^(PhishTracksStatsError *err) {
													  dbug(@"stats err: %@", err);
													  self.popularShows = @[];
												  }];
}

- (BOOL)isDoneLoadingData {
	return self.popularShows != nil;
}

- (NSInteger)collectionCount {
	return self.popularShows.count;
}

- (id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	return self.popularShows[idx];
}

-(void)selectedCollectionAtIndex:(NSInteger)idx {
	PhishTracksStatsPlayEvent *topShow = self.popularShows[idx];
	PhishinShow *show = PhishinShow.new;
	show.date = topShow.showDate;
	
	[self.viewController.navigationController pushViewController:[ShowViewController.alloc initWithShow:show]
														animated:YES];
}

@end

@implementation PHODMyShowsCollectionProvider

- (void)loadData {
	if(!PhishNetAuth.sharedInstance.hasCredentials) {
		[self finishedLoadingData];
		return;
	}
	
	[PhishNetAPI.sharedAPI showsForCurrentUser:^(NSArray *rs) {
		self.myShows = rs;
		[self finishedLoadingData];
	}
									   failure:REQUEST_FAILED(self.viewController.tableView)];
}

- (BOOL)isDoneLoadingData {
	return self.myShows != nil;
}

- (NSInteger)collectionCount {
	return self.myShows.count;
}

- (id<PHODCollection>)collectionForIndex:(NSInteger)idx {
	return self.myShows[idx];
}

-(void)selectedCollectionAtIndex:(NSInteger)idx {
	PhishNetShow *m = self.myShows[idx];
	PhishinShow *show = PhishinShow.new;
	show.date = m.dateString;
	
	[self.viewController.navigationController pushViewController:[ShowViewController.alloc initWithShow:show]
														animated:YES];
}

@end
