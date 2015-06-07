//
//  TopRatedCollectionProvider.h
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

@import UIKit;

@interface PHODCollectionProvider : NSObject<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithContainingViewController:(UITableViewController *)vc
									   inSection:(NSInteger)section;

- (void)loadData;
- (void)finishedLoadingData;

@property (nonatomic) NSInteger collectionCount;
- (id<PHODCollection>)collectionForIndex:(NSInteger)idx;
- (void)selectedCollectionAtIndex:(NSInteger)idx;

@property (nonatomic) UITableViewController *viewController;
@property (nonatomic) NSInteger section;
@property (nonatomic, readonly) BOOL isDoneLoadingData;

@end

@interface PHODTopRatedCollectionProvider : PHODCollectionProvider

@property (nonatomic) NSArray *topRatedShows;

@end

@interface PHODRecentCollectionProvider : PHODCollectionProvider

@property (nonatomic) NSOrderedSet *recentShows;

@end

@interface PHODTodayCollectionProvider : PHODCollectionProvider

@property (nonatomic) NSArray *todaysShows;

@end

@interface PHODPopularCollectionProvider : PHODCollectionProvider

@property (nonatomic) NSArray *popularShows;

@end

@interface PHODMyShowsCollectionProvider : PHODCollectionProvider

@property (nonatomic) NSArray *myShows;

@end
