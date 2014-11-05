//
//  ToursViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ToursViewController.h"

#import "TourViewController.h"
#import "BadgeAndHeatmapCell.h"
#import "PhishTracksStats.h"
#import "PTSHeatmapQuery.h"
#import "PTSHeatmapResults.h"

//#import <TDBadgedCell/TDBadgedCell.h>

@implementation ToursViewController {
	PTSHeatmapResults *_toursHeatmap;
}

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		self.title = @"Tours";
		self.tours = @[];
    }
    return self;
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] tours:^(NSArray *phishinTours) {
		self.tours = phishinTours;
		
		[self.tableView reloadData];
		[super refresh:sender];
	}
						  failure:REQUEST_FAILED(self.tableView)];
	
	[self refreshHeatmap];
}

- (void)refreshHeatmap {
	PTSHeatmapQuery *query = [[PTSHeatmapQuery alloc] initWithAutoTimeframeAndEntity:@"tours" filter:nil];
	
	[PhishTracksStats.sharedInstance globalHeatmapWithQuery:query
													success:^(PTSHeatmapResults *results) {
														_toursHeatmap = results;
														[self.tableView reloadData];
													}
													failure:nil
	 ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tours.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//	TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
	BadgeAndHeatmapCell *cell = (BadgeAndHeatmapCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	if(!cell) {
		cell = [[BadgeAndHeatmapCell alloc] initWithStyle:UITableViewCellStyleSubtitle
								   reuseIdentifier:@"Cell"];
	}
	
	PhishinTour *tour = self.tours[indexPath.row];
	
	cell.textLabel.text = tour.name;
	cell.detailTextLabel.text = tour.prettyDuration;
    cell.badgeColor = UIColor.lightGrayColor;
	cell.badgeString = [NSString stringWithFormat:@"%d", tour.shows_count];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	PhishinTour *tour = self.tours[indexPath.row];
	TourViewController *vc = [[TourViewController alloc] initWithTour:tour];
	[self.navigationController pushViewController:vc
										 animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) * 1.2;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BadgeAndHeatmapCell *scell = (BadgeAndHeatmapCell *)cell;
	PhishinTour *tour = self.tours[indexPath.row];
	float heatmapValue = [_toursHeatmap floatValueForKey:tour.slug];
	[scell updateHeatmapLabelWithValue:heatmapValue];
}

@end
