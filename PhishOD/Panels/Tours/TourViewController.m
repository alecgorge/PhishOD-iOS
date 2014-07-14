//
//  TourViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/9/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "TourViewController.h"
#import "PhishTracksStatsFavoritePopover.h"

@implementation TourViewController

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
}

- (NSArray *)shows {
	return self.tour.shows;
}

@end
