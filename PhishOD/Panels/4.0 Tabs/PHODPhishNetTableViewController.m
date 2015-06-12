//
//  PHODPhishNetTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 5/16/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODPhishNetTableViewController.h"

#import "PHODCollectionProvider.h"
#import "PHODCollectionTableViewCell.h"
#import "PHODLoadingTableViewCell.h"
#import "PHODCollectionCollectionViewCell.h"
#import "Value1SubtitleCell.h"

#import "PhishNetAPI.h"
#import "PhishNetAuth.h"

#import "PhishNetShowsViewController.h"
#import "PhishNetBlogViewController.h"
#import "PhishNetNewsViewController.h"
#import <SVWebViewController/SVWebViewController.h>

#import "PHODTableHeaderView.h"

NS_ENUM(NSInteger, kPHODPhishNetTabSections) {
	kPHODPhishNetTabMyShowsSection,
	kPHODPhishNetTabBlogSection,
	kPHODPhishNetTabNewsSection,
	kPHODPhishNetTabSectionsCount
};

@interface PHODPhishNetTableViewController ()

@property (nonatomic) PHODMyShowsCollectionProvider *myShowsProvider;
@property (nonatomic) NSArray *blog;
@property (nonatomic) NSArray *news;

@end

@implementation PHODPhishNetTableViewController

- (instancetype)init {
	if (self = [super init]) {
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Phish.net"
													  image:[UIImage imageNamed:@"glyphicons-255-fishes"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Phish.net";
    
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODLoadingTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"loadingCell"];

	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODCollectionTableViewCell.class)
											   bundle:nil]
		 forCellReuseIdentifier:@"collectionCell"];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(Value1SubtitleCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"cell"];
	
	[self.tableView registerClass:UITableViewCell.class
		   forCellReuseIdentifier:@"cellPlain"];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 44.0f;
	
	self.myShowsProvider = [PHODMyShowsCollectionProvider.alloc initWithContainingViewController:self
																					   inSection:kPHODPhishNetTabMyShowsSection];
	
	[PhishNetAPI.sharedAPI news:^(NSArray *a) {
		self.news = a;
		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kPHODPhishNetTabNewsSection]
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}
						failure:REQUEST_FAILED(self.tableView)];
	
	[PhishNetAPI.sharedAPI blog:^(NSArray *a) {
		self.blog = a;
		
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kPHODPhishNetTabBlogSection]
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}
						failure:REQUEST_FAILED(self.tableView)];

}

- (NSArray *)arrayForSection:(NSInteger)section {
	if (section == kPHODPhishNetTabMyShowsSection) {
		return self.myShowsProvider.myShows;
	}
	else if(section == kPHODPhishNetTabBlogSection) {
		return self.blog;
	}
	else if(section == kPHODPhishNetTabNewsSection) {
		return self.news;
	}
	
	return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kPHODPhishNetTabSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if (section == kPHODPhishNetTabMyShowsSection) {
		return 1;
	}
	
	NSArray *arr = [self arrayForSection:section];
	return arr == nil ? 1 : MIN(5, arr.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if (indexPath.section == kPHODPhishNetTabMyShowsSection) {
		if (PhishNetAuth.sharedInstance.hasCredentials) {
			if(!self.myShowsProvider.isDoneLoadingData) {
				cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"
													   forIndexPath:indexPath];
				
				PHODLoadingTableViewCell *c = (PHODLoadingTableViewCell*)cell;
				[c.uiActivityIndicator startAnimating];
			}
			else {
				cell = [tableView dequeueReusableCellWithIdentifier:@"collectionCell"
													   forIndexPath:indexPath];
				
				PHODCollectionTableViewCell *c = (PHODCollectionTableViewCell *)cell;
				
				c.uiCollectionView.delegate = self.myShowsProvider;
				c.uiCollectionView.dataSource = self.myShowsProvider;
				
				[c.uiCollectionView reloadData];
			}
		}
		else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"cellPlain"
												   forIndexPath:indexPath];
			
			cell.textLabel.text = @"Sign into phish.net in the settings";
		}
	}
	else {
		NSArray *a = [self arrayForSection:indexPath.section];
		
		if(a == nil) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"
												   forIndexPath:indexPath];
			
			PHODLoadingTableViewCell *c = (PHODLoadingTableViewCell*)cell;
			[c.uiActivityIndicator startAnimating];
		}
		else {
			cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
												   forIndexPath:indexPath];
			
			if(indexPath.section == kPHODPhishNetTabBlogSection) {
				Value1SubtitleCell *c = (Value1SubtitleCell*)cell;
				
				PhishNetBlogItem *item = a[indexPath.row];
				
				NSDateFormatter *f = NSDateFormatter.alloc.init;
				f.dateStyle = NSDateFormatterShortStyle;
				f.timeStyle = NSDateFormatterNoStyle;
				
				c.titleLabel.text = item.title;
				c.subtitleLabel.text = item.author;
				c.value1Label.text = [f stringFromDate:item.date];
			}
			else if(indexPath.section == kPHODPhishNetTabNewsSection) {
				Value1SubtitleCell *c = (Value1SubtitleCell*)cell;
				
				PhishNetNewsItem *item = a[indexPath.row];
				
				NSDateFormatter *f = NSDateFormatter.alloc.init;
				f.dateStyle = NSDateFormatterShortStyle;
				f.timeStyle = NSDateFormatterNoStyle;
				
				c.titleLabel.text = item.title;
				c.subtitleLabel.text = item.author;
				c.value1Label.text = [f stringFromDate:item.date];
			}
		}
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if (section == kPHODPhishNetTabMyShowsSection) {
		return @"My Shows";
	}
	else if(section == kPHODPhishNetTabBlogSection) {
		return @"Phish.net Blog";
	}
	else if(section == kPHODPhishNetTabNewsSection) {
		return @"Phish.net News";
	}
	
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
	CGFloat barHeight = 35.0f;
	CGFloat buttonWidth = 50.0f;
	
	NSString *title = [tableView.dataSource tableView:tableView
							  titleForHeaderInSection:section];
	
	PHODTableHeaderView *v = [PHODTableHeaderView.alloc initWithFrame:CGRectMake(0,
																				 0,
																				 self.tableView.bounds.size.width,
																				 barHeight)
															 andTitle:[title uppercaseString]];
	v.buttonWidth = buttonWidth;
	
	[v addTarget:self
		  action:@selector(viewMoreForSectionButton:)];
	
	v.moreButton.tag = section;
	
	return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0f;
}

- (void)viewMoreForSectionButton:(UIButton *)sender {
	if(sender.tag == kPHODPhishNetTabMyShowsSection) {
		[self.navigationController pushViewController:[PhishNetShowsViewController.alloc initWithShows:self.myShowsProvider.myShows]
											 animated:YES];
	}
	else if(sender.tag == kPHODPhishNetTabBlogSection) {
		[self.navigationController pushViewController:[PhishNetBlogViewController.alloc initWithBlog:self.blog]
											 animated:YES];
	}
	else if(sender.tag == kPHODPhishNetTabNewsSection) {
		[self.navigationController pushViewController:[PhishNetNewsViewController.alloc initWithNews:self.news]
											 animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kPHODPhishNetTabMyShowsSection) {
		return [PHODCollectionCollectionViewCell rowHeight];
	}
	
	return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == kPHODPhishNetTabBlogSection) {
		PhishNetBlogItem *item = self.blog[indexPath.row];
		
		SVWebViewController *vc = [SVWebViewController.alloc initWithURL:item.URL];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else if(indexPath.section == kPHODPhishNetTabNewsSection) {
		PhishNetNewsItem *item = self.news[indexPath.row];
		
		SVWebViewController *vc = [SVWebViewController.alloc initWithURL:item.URL];
		[self.navigationController pushViewController:vc
											 animated:YES];
	}	
}

@end
