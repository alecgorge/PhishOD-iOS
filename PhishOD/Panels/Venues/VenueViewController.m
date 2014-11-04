//
//  VenueViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "VenueViewController.h"
#import "PDLocationsMap.h"
#import "ShowViewController.h"
#import "PhishTracksStatsFavoritePopover.h"

@implementation VenueViewController

typedef enum {
	kPhishODVenueName,
    kPhishODVenuePastNames,
	kPhishODVenueCity,
	kPhishODVenueShowCount,
    kPhishODVenueRowCount
} kPhishODVenueRow;

typedef enum {
	kPhishODVenueInfoSection,
	kPhishODVenueShowsSection,
	kPhishODVenueSectionCount
} kPhishODVenueSection;

- (instancetype)initWithVenue:(PhishinVenue *)venue {
    self = [super initWithDelegate:self
					 andDataSource:self];
    if (self) {
        self.venue = venue;
		self.title = venue.name;
		
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[spinner startAnimating];
		spinner.frame = CGRectMake(0, 0, 320, 44);
		self.tableView.tableFooterView = spinner;
		
		[[PhishinAPI sharedAPI] fullVenue:self.venue
								  success:^(PhishinVenue *venue) {
									  self.venue = venue;
									  
									  self.tableView.tableFooterView = nil;
									  [self.tableView reloadData];
								  }
								  failure:REQUEST_FAILED(self.tableView)];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupRightBarButtonItem];
}

- (void)setupRightBarButtonItem {
    UIImage *customImage = [UIImage heartIconWhite];
    UIBarButtonItem *customBarButtonItem = [[UIBarButtonItem alloc] initWithImage:customImage
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(favoriteTapped:)];
    
    self.navigationItem.rightBarButtonItem = customBarButtonItem;
}

- (void)favoriteTapped:(id)sender {
    [PhishTracksStatsFavoritePopover.sharedInstance showFromBarButtonItem:sender
                                                                   inView:self.view
                                                        withPhishinObject:_venue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kPhishODVenueSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section  {
	if(section == kPhishODVenueInfoSection) {
		return kPhishODVenueRowCount;
	}
	else {
		return self.venue.show_dates.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if(indexPath.section == kPhishODVenueInfoSection) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"keyValue"];
		
		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
										  reuseIdentifier:@"keyValue"];
		}
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

		if (!cell) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"cell"];
		}
	}
	
	if(indexPath.section == kPhishODVenueInfoSection) {
		if(indexPath.row == kPhishODVenueName) {
			cell.textLabel.text = @"Name";
			cell.detailTextLabel.text = self.venue.name;
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if(indexPath.row == kPhishODVenueCity) {
			cell.textLabel.text = @"City";
			cell.detailTextLabel.text = self.venue.location;
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if(indexPath.row == kPhishODVenueShowCount) {
			cell.textLabel.text = @"Show Count";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.venue.shows_count];
			
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
        else if(indexPath.row == kPhishODVenuePastNames) {
            cell.textLabel.text = @"Past Names";
            cell.detailTextLabel.text = self.venue.past_names;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
	}
	else {
		NSString *show_date = self.venue.show_dates[indexPath.row];
		
		cell.textLabel.text = show_date;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == kPhishODVenueShowsSection) {
		NSString *show_date = self.venue.show_dates[indexPath.row];
		NSInteger show_id = [self.venue.show_ids[indexPath.row] integerValue];
		
		PhishinShow *show = [[PhishinShow alloc] init];
		show.id = (int)show_id;
		show.date = show_date;
		
		ShowViewController *vc = [[ShowViewController alloc] initWithShow:show];
		[self.navigationController pushViewController:vc
											 animated:YES];		
	}
}

- (NSArray *)locationsForShowingInLocationsMap {
	return @[[[PDLocation alloc] initWithName:self.venue.name
								  description:self.venue.location
								  andLocation:CLLocationCoordinate2DMake(self.venue.latitude, self.venue.longitude)]];
}

- (void)didSelectLocationAtIndex:(int)index {
	
}

@end
