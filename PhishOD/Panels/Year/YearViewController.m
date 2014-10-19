//
//  YearViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearViewController.h"
#import <TDBadgedCell/TDBadgedCell.h>
#import "ShowViewController.h"
#import "ShowCell.h"
#import "PhishTracksStats.h"
#import "PTSHeatmapQuery.h"
#import "PTSHeatmapResults.h"

@interface YearViewController ()

@end

@implementation YearViewController {
	PTSHeatmapResults *_yearHeatmap;
}

- (id)initWithYear:(PhishinYear*)y {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.year = y;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 55;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
	
	self.title = self.year.year;
	
	NSArray *itemArray = @[@"All", @"SBD or Remastered"];
	control = [[UISegmentedControl alloc] initWithItems:itemArray];
	control.frame = CGRectMake(0, 10.0, self.tableView.bounds.size.width - 20, 30.0);
	control.selectedSegmentIndex = 0;
	[control addTarget:self
				action:@selector(doFilterShows)
	  forControlEvents:UIControlEventValueChanged];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ShowCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"show"];
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] fullYear:self.year
							 success:^(PhishinYear *yy) {
								 self.year = yy;
								 [self.tableView reloadData];
								 
								 [super refresh:sender];
							 }
							 failure:REQUEST_FAILED(self.tableView)];
	[self refreshHeatmap];
}

- (void)refreshHeatmap {
	PTSHeatmapQuery *query = [[PTSHeatmapQuery alloc] initWithEntity:@"year" timeframe:@"all_time" filter:self.year.year];
	
	[PhishTracksStats.sharedInstance globalHeatmapWithQuery:query
        success:^(PTSHeatmapResults *results) {
			_yearHeatmap = results;
			[self.tableView reloadData];
    	}
        failure:nil
    	];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSArray *)shows {
	return self.year.shows;
}

- (NSArray *)doFilterShows {
	if(control.selectedSegmentIndex == 0) {
		filteredShows = self.shows;
	}
	else if(control.selectedSegmentIndex == 1) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.remastered == YES OR SELF.sbd == YES"];
		filteredShows = [self.shows filteredArrayUsingPredicate:pred];
	}
	else {
		filteredShows = self.shows;
	}
	
	[self.tableView reloadData];
	
	return filteredShows;
}


- (NSArray *)filteredShows {
	if(filteredShows != nil) {
		return filteredShows;
	}
	else {
		return [self doFilterShows];
	}
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.shows.count) {
		return [self filteredShows].count;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
	if(section == 0) {
        UIToolbar *headerView = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 44)];
		headerView.barTintColor = [UIColor whiteColor];
        
		control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
        [headerView setItems:@[flexibleSpace,[[UIBarButtonItem alloc] initWithCustomView:control],flexibleSpace]];
        return headerView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return 44.0f;
	}
	return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishinShow *show = (PhishinShow*)[self filteredShows][indexPath.row];
	
	ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
													 forIndexPath:indexPath];

	[cell updateCellWithShow:show
				 inTableView:tableView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *scell = (ShowCell *)cell;
	PhishinShow *show = (PhishinShow*)[self filteredShows][indexPath.row];
	float heatmapValue = [_yearHeatmap floatValueForKey:show.date];
	[scell updateHeatmapLabelWithValue:heatmapValue];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishinShow *show = [self filteredShows][indexPath.row];
    [self.navigationController pushViewController:[[ShowViewController alloc] initWithShow: show]
										 animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView
//heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"];
//	
//	PhishinShow *show = (PhishinShow*)[self filteredShows][indexPath.row];
//
//	return [cell heightForCellWithShow:show
//						   inTableView:tableView];
//}

@end
