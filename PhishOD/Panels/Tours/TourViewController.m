//
//  TourViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TourViewController.h"
#import "PhishTracksStats.h"
#import "PhishTracksStatsFavoritePopover.h"
#import "PTSHeatmapQuery.h"
#import "PTSHeatmapResults.h"
#import "ShowCell.h"

@implementation TourViewController {
	PTSHeatmapResults *_tourHeatmap;
}

- (id)initWithTour:(PhishinTour *)tour {
    self = [super initWithYear:nil];
    if (self) {
        self.tour = tour;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = self.tour.name;
	[self setupRightBarButtonItem];
}

- (void)setupRightBarButtonItem {
    UIImage *customImage = [UIImage heartIconWhite];
    UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithImage:customImage
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(favoriteTapped:)];
    
    self.navigationItem.rightBarButtonItem = customBarButtonItem;
}

- (void)favoriteTapped:(id)sender {
    [PhishTracksStatsFavoritePopover.sharedInstance showFromBarButtonItem:sender
                                                                   inView:self.view
                                                        withPhishinObject:_tour];
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] fullTour:self.tour
							 success:^(PhishinTour *tour) {
								 self.tour = tour;
								 
								 [self.tableView reloadData];
								 [sender endRefreshing];
							 }
							 failure:REQUEST_FAILED(self.tableView)];
	[self refreshHeatmap];
}

- (void)refreshHeatmap {
	PTSHeatmapQuery *query = [[PTSHeatmapQuery alloc] initWithEntity:@"tour" timeframe:@"all_time" filter:self.tour.name];
	
	[PhishTracksStats.sharedInstance globalHeatmapWithQuery:query
        success:^(PTSHeatmapResults *results) {
			_tourHeatmap = results;
			[self.tableView reloadData];
    	}
        failure:nil//^(PhishTracksStatsError *err) {
    	];
}

- (NSArray *)shows {
	return self.tour.shows;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *scell = (ShowCell *)cell;
	PhishinShow *show = (PhishinShow*)[self shows][indexPath.row];
	float heatmapValue = [_tourHeatmap floatValueForKey:show.date];
	[scell updateHeatmapLabelWithValue:heatmapValue];
}

@end
