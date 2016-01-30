//
//  PHODDownloadTabTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/9/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODDownloadTabTableViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <KVOController/FBKVOController.h>
#import <Toast/UIView+Toast.h>

#import "PHODTrackCell.h"
#import "PHODCollectionTableViewCell.h"
#import "PHODCollectionProvider.h"
#import "PHODCollectionCollectionViewCell.h"
#import "PHODLoadingTableViewCell.h"
#import "PHODDownloadingTrackCell.h"
#import "PHODTableHeaderView.h"

#import "IGAPIClient.h"
#import "IGShowCell.h"
#import "RLShowViewController.h"
#import "AppDelegate.h"
#import "NowPlayingBarViewController.h"

NS_ENUM(NSInteger, kPHODDownloadTabSections) {
	kPHODDownloadTabDownloadedSection,
	kPHODDownloadTabDownloadingSection,
    kPHODDownloadTabQueueSection,
	kPHODDownloadTabDownloadSectionCount
};

@interface PHODDownloadTabTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, PHODDownloaderDelegate>

#ifdef IS_PHISH
@property (nonatomic) PHODDownloadedCollectionProvider *downloadedProvider;
#else
@property (nonatomic) NSArray *downloadedShows;
#endif

@property (nonatomic, readonly) NSArray<PHODDownloadItem *> *downloading;
@property (nonatomic, readonly) NSArray<PHODDownloadItem *> *downloadQueue;

@end

@implementation PHODDownloadTabTableViewController

- (instancetype)init {
	if (self = [super init]) {
		// set up tab bar
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Downloads"
													  image:[UIImage imageNamed:@"glyphicons-135-inbox-in"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
	}
	return self;
}

- (NSArray<PHODDownloadItem *> *)downloading {
    return self.downloader.downloading;
}

- (NSArray<PHODDownloadItem *> *)downloadQueue {
    return self.downloader.downloadQueue;
}

- (PHODDownloader *)downloader {
    PHODDownloader *manager;
    
#ifdef IS_PHISH
    manager = PhishinAPI.sharedAPI.downloader;
#else
    manager = IGDownloader.sharedInstance;
#endif
    
    return manager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.downloader.delegate = self;
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODDownloadingTrackCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:PHODDownloadingTrackCellIdentifier];
    
#ifdef IS_PHISH
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODLoadingTableViewCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:@"loadingCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODCollectionTableViewCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:@"collectionCell"];
    
    self.downloadedProvider = [PHODDownloadedCollectionProvider.alloc initWithContainingViewController:self
                                                                                             inSection:kPHODDownloadTabDownloadedSection];
#else
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:nil]
         forCellReuseIdentifier:@"show"];
#endif
    
#ifndef IS_PHISH
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
#endif
    
	self.tableView.estimatedRowHeight = 44.0f;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#ifndef IS_PHISH
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
    } else {
        [AppDelegate.sharedDelegate.navDelegate fixForViewController:self force:true];
    }
}
#endif

#ifndef IS_PHISH
- (void)refresh:(id)sender {
    [IGDownloadItem showsWithCachedTracks:^(NSArray *shows) {
        self.downloadedShows = [shows sortedArrayUsingComparator:^NSComparisonResult(IGShow *s1, IGShow *s2) {
            return [s2.date compare:s1.date];
        }];
        
        [self.tableView reloadData];
        [super refresh:sender];
    }];
}
#endif

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
#ifdef IS_PHISH
    [self.downloadedProvider loadData];
    [self.tableView reloadData];
#else
    [self refresh:nil];
    self.navigationItem.title = self.title = @"Downloads";
#endif
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == kPHODDownloadTabDownloadedSection) {
		return @"Available Offline";
	}
	else if(section == kPHODDownloadTabDownloadingSection) {
		return @"Downloading";
	}
    else if(section == kPHODDownloadTabQueueSection) {
        return [NSString stringWithFormat:@"%ld Queued", self.downloadQueue.count];
    }
	
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
	CGFloat barHeight = 35.0f;
	
	NSString *title = [tableView.dataSource tableView:tableView
							  titleForHeaderInSection:section];
	
	PHODTableHeaderView *v = [PHODTableHeaderView.alloc initWithFrame:CGRectMake(0,
																				 0,
																				 self.tableView.bounds.size.width,
																				 barHeight)
															 andTitle:[title uppercaseString]];
	
	if(section == kPHODDownloadTabDownloadedSection) {
		v.buttonWidth = 100.0f;
		[v addTarget:self
			  action:@selector(deleteCache)];
		[v.moreButton setTitle:@"DELETE"
					  forState:UIControlStateNormal];
	}
	
	return v;
}

- (void)deleteCache {
#ifdef IS_PHISH
    long long size = [PHODDownloadItem completeCachedSize];
#else
    long long size = [IGDownloadItem completeCachedSize];
#endif
    
	NSString *space = [NSByteCountFormatter stringFromByteCount:size
													 countStyle:NSByteCountFormatterCountStyleFile];
	UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Delete Downloaded Songs?"
															   message:[NSString stringWithFormat:@"Do you want to delete all your downloaded songs? Doing this will free up %@ of space.", space]
														preferredStyle:UIAlertControllerStyleActionSheet];
	
	[a addAction:[UIAlertAction actionWithTitle:@"Delete"
										  style:UIAlertActionStyleDestructive
										handler:^(UIAlertAction *action) {
#ifdef IS_PHISH
                                            [PHODDownloadItem deleteEntireCache];
#else
                                            [IGDownloadItem deleteEntireCache];
#endif

                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                [self.tableView reloadData];
                                            });
										}]];
	
	[a addAction:[UIAlertAction actionWithTitle:@"Keep jamming"
										  style:UIAlertActionStyleCancel
										handler:nil]];
	
	[self presentViewController:a
					   animated:YES
					 completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
	return 35.0f;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kPHODDownloadTabDownloadSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == kPHODDownloadTabDownloadedSection) {
#ifdef IS_PHISH
        return 1;
#else
        return self.downloadedShows.count;
#endif
	}
	else if(section == kPHODDownloadTabDownloadingSection) {
		return self.downloading.count;
	}
    else if(section == kPHODDownloadTabQueueSection) {
        return self.downloadQueue.count;
    }
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if(indexPath.section == kPHODDownloadTabDownloadedSection) {
#ifdef IS_PHISH
        if (self.downloadedProvider.isDoneLoadingData) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"
                                                   forIndexPath:indexPath];
            
            PHODCollectionTableViewCell *c = (PHODCollectionTableViewCell *)cell;
            
            c.uiCollectionView.delegate = self.downloadedProvider;
            c.uiCollectionView.dataSource = self.downloadedProvider;
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
#else
        IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
                                                           forIndexPath:indexPath];
        
        [cell updateCellWithShow:self.downloadedShows[indexPath.row]];
        
        return cell;
#endif
	}
    else if(indexPath.section == kPHODDownloadTabDownloadingSection) {
        cell =  [tableView dequeueReusableCellWithIdentifier:PHODDownloadingTrackCellIdentifier
                                                forIndexPath:indexPath];
        
        PHODDownloadingTrackCell *c = (PHODDownloadingTrackCell *)cell;
        
        if(indexPath.row >= self.downloading.count) {
            return cell;
        }
        
        [c updateCellWithDownloadItem:self.downloading[indexPath.row]];
    }
    else if(indexPath.section == kPHODDownloadTabQueueSection) {
        cell =  [tableView dequeueReusableCellWithIdentifier:PHODDownloadingTrackCellIdentifier
                                                forIndexPath:indexPath];
        
        PHODDownloadingTrackCell *c = (PHODDownloadingTrackCell *)cell;
        
        if(indexPath.row >= self.downloadQueue.count) {
            return cell;
        }
        
        [c updateCellWithDownloadItem:self.downloadQueue[indexPath.row]];
    }
    
    // Configure the cell...
    
    return cell;
}

#ifndef IS_PHISH
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.section == kPHODDownloadTabDownloadedSection) {
        IGShow *show = self.downloadedShows[indexPath.row];
        RLShowViewController *vc = [RLShowViewController.alloc initWithShow:show];
        
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    else if(indexPath.section == kPHODDownloadTabDownloadingSection) {
        IGDownloadItem *i = (IGDownloadItem *)self.downloading[indexPath.row];
        RLShowViewController *vc = [RLShowViewController.alloc initWithShow:i.show];
        
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    else if(indexPath.section == kPHODDownloadTabQueueSection) {
        IGDownloadItem *i = (IGDownloadItem *)self.downloadQueue[indexPath.row];
        RLShowViewController *vc = [RLShowViewController.alloc initWithShow:i.show];
        
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}
#endif

#ifdef IS_PHISH
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == kPHODDownloadTabDownloadedSection) {
        return [PHODCollectionCollectionViewCell rowHeight];
    }
    
    return UITableViewAutomaticDimension;
}
#endif

#pragma mark - Download Delegate

- (void)animateTwoSections {
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(kPHODDownloadTabDownloadingSection, kPHODDownloadTabQueueSection - kPHODDownloadTabDownloadingSection + 1)]
//                  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)downloader:(PHODDownloader *)downloader
     itemCancelled:(PHODDownloadItem *)item {
    [self animateTwoSections];
}

- (void)downloader:(PHODDownloader *)downloader
        itemFailed:(PHODDownloadItem *)item {
    [self animateTwoSections];
}

- (void)downloader:(PHODDownloader *)downloader
      itemSucceded:(PHODDownloadItem *)item {
//    [self.tableView reloadData];
    [self animateTwoSections];
    
//    [self.view makeToast:[NSString stringWithFormat:@"%@ finished downloading", [[item track] title]]
//                duration:5.0f
//                position:CSToastPositionBottom];
}

- (void)downloader:(PHODDownloader *)downloader
       itemStarted:(PHODDownloadItem *)item {
    [self animateTwoSections];
}

#pragma mark - Empty Data Set

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
	NSString *text = @"No Downloaded Shows :(";
	
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0],
								 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
	
	return [NSAttributedString.alloc initWithString:text
										 attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
	
	NSString *text = @"You can download individual tracks or complete shows from the show screen by tapping the cloud icon by the track to start the download.";
	
	NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
	paragraph.lineBreakMode = NSLineBreakByWordWrapping;
	paragraph.alignment = NSTextAlignmentCenter;
	
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
								 NSForegroundColorAttributeName: [UIColor lightGrayColor],
								 NSParagraphStyleAttributeName: paragraph};
	
	return [NSAttributedString.alloc initWithString:text
										 attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
	return NO;
}

@end
