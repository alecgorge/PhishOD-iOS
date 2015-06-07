//
//  PhishNetNewsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/30/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetNewsViewController.h"

#import <SVWebViewController/SVWebViewController.h>

#import "PhishNetAPI.h"
#import "Value1SubtitleCell.h"

@interface PhishNetNewsViewController ()

@property (nonatomic) NSArray *news;
@property (nonatomic) BOOL skipLoading;

@end

@implementation PhishNetNewsViewController

- (instancetype)initWithNews:(NSArray *)array {
	if (self = [super init]) {
		self.news = array;
		self.skipLoading = YES;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Phish.net News";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(Value1SubtitleCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"cell"];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 44.0f;
}

- (void)refresh:(id)sender {
	if (self.skipLoading) {
		[self.tableView reloadData];
		self.skipLoading = NO;
		[super refresh:sender];
		return;
	}
	
	[PhishNetAPI.sharedAPI news:^(NSArray *news) {
		self.news = news;
		
		[self.tableView reloadData];
		[super refresh:sender];
	}
						failure:REQUEST_FAILED(self.tableView)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.news ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Value1SubtitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
															   forIndexPath:indexPath];
	
	PhishNetNewsItem *item = self.news[indexPath.row];
	
	NSDateFormatter *f = NSDateFormatter.alloc.init;
	f.dateStyle = NSDateFormatterShortStyle;
	f.timeStyle = NSDateFormatterNoStyle;
	
	cell.titleLabel.text = item.title;
	cell.subtitleLabel.text = item.author;
	cell.value1Label.text = [f stringFromDate:item.date];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishNetNewsItem *item = self.news[indexPath.row];
	
	SVWebViewController *vc = [SVWebViewController.alloc initWithURL:item.URL];
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end
