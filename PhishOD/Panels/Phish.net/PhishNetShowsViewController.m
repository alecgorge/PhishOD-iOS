//
//  PhishNetShowsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/30/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetShowsViewController.h"

#import "PhishNetAPI.h"
#import "Value1SubtitleCell.h"
#import "ShowViewController.h"

@interface PhishNetShowsViewController ()

@property (nonatomic) NSArray *shows;
@property (nonatomic) BOOL skipLoadingShows;

@end

@implementation PhishNetShowsViewController

- (instancetype)initWithShows:(NSArray *)shows {
	if (self = [super init]) {
		self.shows = shows;
		self.skipLoadingShows = YES;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"My Shows";
}

- (void)refresh:(id)sender {
	if (self.skipLoadingShows) {
		[self.tableView reloadData];
		self.skipLoadingShows = NO;
		[super refresh:sender];
		return;
	}
	
	[PhishNetAPI.sharedAPI showsForCurrentUser:^(NSArray *shows) {
		self.shows = shows;
		
		[self.tableView reloadData];
		[super refresh:sender];
	}
									   failure:REQUEST_FAILED(self.tableView)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.shows ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return self.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if(!cell) {
		cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
									reuseIdentifier:@"cell"];
	}
	
	PhishNetShow *item = self.shows[indexPath.row];
	
	cell.textLabel.text = item.dateString;
	
	cell.detailTextLabel.text = item.venue;
	cell.detailTextLabel.numberOfLines = 0;
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishNetShow *item = self.shows[indexPath.row];

	CGRect rect = [item.venue boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 30.0f, CGFLOAT_MAX)
										   options:NSStringDrawingUsesLineFragmentOrigin
										attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0]}
										   context:nil];
	
	return MAX((tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) + 15, 7 + 20 + rect.size.height + 7);
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishNetShow *item = self.shows[indexPath.row];
	
	PhishinShow *show = PhishinShow.alloc.init;
	show.date = item.dateString;
	
	ShowViewController *vc = [ShowViewController.alloc initWithShow:show];
	[self.navigationController pushViewController:vc
										 animated:YES];
}

@end
