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

#import "PHODTrackCell.h"
#import "PHODCollectionTableViewCell.h"
#import "PHODCollectionProvider.h"
#import "PHODCollectionCollectionViewCell.h"
#import "PHODLoadingTableViewCell.h"
#import "PHODTableHeaderView.h"

#import "IGAPIClient.h"
#import "IGShowCell.h"
#import "RLShowViewController.h"
#import "AppDelegate.h"

NS_ENUM(NSInteger, kPHODDownloadTabSections) {
	kPHODDownloadTabDownloadedSection,
	kPHODDownloadTabDownloadingSection,
	kPHODDownloadTabDownloadSectionCount
};

@interface PHODDownloadTabTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

#ifdef IS_PHISH
@property (nonatomic) PHODDownloadedCollectionProvider *downloadedProvider;
#else
@property (nonatomic) NSArray *downloadedShows;
#endif

@property (nonatomic) NSOperationQueue *downloading;
@property (nonatomic) FBKVOController *kvo;

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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tabBarController.title = @"Downloads";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"trackCell"];
    
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
    
#ifdef IS_PHISH
    self.downloading = PhishinAPI.sharedAPI.downloader.queue;
#else
    self.downloading = IGDownloader.sharedInstance.queue;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
#endif
    
	self.kvo = [FBKVOController.alloc initWithObserver:self];
	
	[self.kvo observe:self.downloading
			  keyPath:@"count"
			  options:NSKeyValueObservingOptionNew
				block:^(id observer, id object, NSDictionary *change) {
					[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, kPHODDownloadTabDownloadSectionCount)]
								  withRowAnimation:UITableViewRowAnimationAutomatic];
				}];
	
	self.tableView.estimatedRowHeight = 44.0f;
	self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#ifndef IS_PHISH
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self force:true];
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

											[self.tableView reloadData];
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
		return self.downloading.operations.count;
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
		cell =  [tableView dequeueReusableCellWithIdentifier:@"trackCell"
												forIndexPath:indexPath];
		
		PHODTrackCell *c = (PHODTrackCell *)cell;
		
		if(indexPath.row >= self.downloading.operationCount) {
			return cell;
		}
		
		PHODDownloadOperation *op = self.downloading.operations[indexPath.row];
		PhishinDownloadItem *item = (PhishinDownloadItem *)op.item;
		[c updateCellWithTrack:item.track
				   inTableView:self.tableView];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
