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

NS_ENUM(NSInteger, kPHODDownloadTabSections) {
	kPHODDownloadTabDownloadedSection,
	kPHODDownloadTabDownloadingSection,
	kPHODDownloadTabDownloadSectionCount
};

@interface PHODDownloadTabTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic) PHODDownloadedCollectionProvider *downloadedProvider;

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
	
	self.title = @"Downloads";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODCollectionTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"collectionCell"];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"trackCell"];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODLoadingTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"loadingCell"];

	self.downloadedProvider = [PHODDownloadedCollectionProvider.alloc initWithContainingViewController:self
																							 inSection:kPHODDownloadTabDownloadedSection];
	self.downloading = PhishinAPI.sharedAPI.downloader.queue;
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.downloadedProvider loadData];
	[self.tableView reloadData];
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
	NSString *space = [NSByteCountFormatter stringFromByteCount:[PHODDownloadItem completeCachedSize]
													 countStyle:NSByteCountFormatterCountStyleFile];
	UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Delete Downloaded Songs?"
															   message:[NSString stringWithFormat:@"Do you want to delete all your downloaded songs? Doing this will free up %@ of space.", space]
														preferredStyle:UIAlertControllerStyleActionSheet];
	
	[a addAction:[UIAlertAction actionWithTitle:@"Delete"
										  style:UIAlertActionStyleDestructive
										handler:^(UIAlertAction *action) {
											[PHODDownloadItem deleteEntireCache];

											[self.downloadedProvider loadData];
											[self.tableView reloadData];
											
											[self dismissViewControllerAnimated:YES
																	 completion:nil];
										}]];
	
	[a addAction:[UIAlertAction actionWithTitle:@"Keep jamming"
										  style:UIAlertActionStyleCancel
										handler:^(UIAlertAction *action) {
											[self dismissViewControllerAnimated:YES
																	 completion:nil];
										}]];
	
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
		return 1;
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

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == kPHODDownloadTabDownloadedSection) {
		return [PHODCollectionCollectionViewCell rowHeight];
	}
	
	return UITableViewAutomaticDimension;
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
