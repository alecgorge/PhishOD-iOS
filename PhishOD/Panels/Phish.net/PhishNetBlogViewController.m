//
//  PhishNetBlogViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetBlogViewController.h"

#import <SVWebViewController/SVWebViewController.h>

#import "PhishNetAPI.h"
#import "Value1SubtitleCell.h"

@interface PhishNetBlogViewController ()

@property (nonatomic) NSArray *blog;

@end

@implementation PhishNetBlogViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Phish.net Blog";

	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(Value1SubtitleCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"cell"];
}

- (void)refresh:(id)sender {
	[PhishNetAPI.sharedAPI blog:^(NSArray *blog) {
		self.blog = blog;
		
		[self.tableView reloadData];
		[super refresh:sender];
	}
						failure:REQUEST_FAILED(self.tableView)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.blog ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.blog.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Value1SubtitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
															   forIndexPath:indexPath];
	
	PhishNetBlogItem *item = self.blog[indexPath.row];
	
	NSDateFormatter *f = NSDateFormatter.alloc.init;
	f.dateStyle = NSDateFormatterShortStyle;
	f.timeStyle = NSDateFormatterNoStyle;
	
	cell.titleLabel.text = item.title;
	cell.subtitleLabel.text = item.author;
	cell.value1Label.text = [f stringFromDate:item.date];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Value1SubtitleCell.height;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishNetBlogItem *item = self.blog[indexPath.row];
	
	SVWebViewController *vc = [SVWebViewController.alloc initWithURL:item.URL];
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end
