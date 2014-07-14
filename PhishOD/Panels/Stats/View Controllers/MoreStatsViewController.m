//
//  MoreStatsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 12/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "MoreStatsViewController.h"
#import "StatsQueries.h"
#import "TrackStatsViewController.h"
#import "SetStatsViewController.h"
#import "ShowStatsViewController.h"
#import "TourStatsViewController.h"
#import "VenueStatsViewController.h"
#import "YearStatsViewController.h"

typedef enum {
    kMoreStatsSectionTracks,
    kMoreStatsSectionSets,
    kMoreStatsSectionShows,
    kMoreStatsSectionTours,
    kMoreStatsSectionVenues,
    kMoreStatsSectionYears,
    kMoreStatsSectionEras,
    kMoreStatsSectionCount
} MoreStatsSections;

typedef enum {
    kTracksSectionMenuItem20Min,
    kTracksSectionMenuItemCount
} MoreStatsTracksSection;

typedef enum {
    kSetsSectionMenuItemTopSets,
    kSetsSectionMenuItemCount
} MoreStatsSetsSection;

typedef enum {
    kShowsSectionMenuItemTopShows,
    kShowsSectionMenuItemCount
} MoreStatsShowsSection;

typedef enum {
    kToursSectionMenuItemTopTours,
    kToursSectionMenuItemCount
} MoreStatsToursSection;

typedef enum {
    kVenuesSectionMenuItemTopVenues,
    kVenuesSectionMenuItemCount
} MoreStatsVenuesSection;

typedef enum {
    kYearsSectionMenuItemTopYears,
    kYearsSectionMenuItemStaticCount
} MoreStatsYearsSection;


typedef enum {
    kErasSectionMenuItemTopTracksfor1,
    kErasSectionMenuItemTopTracksfor2,
    kErasSectionMenuItemTopTracksfor3,
    kErasSectionMenuItemCount
} MoreStatsErasSection;

@interface MoreStatsViewController ()

@end

@implementation MoreStatsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"More Stats";
    }
    return self;
}

+ (NSArray *)years
{
    static NSArray *years = nil;
    if (!years) {
        years = @[@1983, @1984, @1985, @1986, @1987, @1988, @1989, @1990, @1991, @1992, @1993, @1994, @1995,
                  @1996, @1997, @1998, @1999, @2000, @2002, @2003, @2004, @2009,
                  @2010, @2011, @2012, @2013];
    }
    return years;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kMoreStatsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kMoreStatsSectionTracks) {
        return kTracksSectionMenuItemCount;
    }
    else if (section == kMoreStatsSectionSets) {
        return kSetsSectionMenuItemCount;
    }
    else if (section == kMoreStatsSectionShows) {
        return kShowsSectionMenuItemCount;
    }
    else if (section == kMoreStatsSectionTours) {
        return kToursSectionMenuItemCount;
    }
    else if (section == kMoreStatsSectionVenues) {
        return kVenuesSectionMenuItemCount;
    }
    else if (section == kMoreStatsSectionYears) {
        return kYearsSectionMenuItemStaticCount + [MoreStatsViewController years].count;
    }
    else if (section == kMoreStatsSectionEras) {
        return kErasSectionMenuItemCount;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == kMoreStatsSectionTracks) {
        if (indexPath.row == kTracksSectionMenuItem20Min) {
            cell.textLabel.text = @"Over 20 Minutes";
        }
    }
    else if (indexPath.section == kMoreStatsSectionSets) {
        if (indexPath.row == kSetsSectionMenuItemTopSets) {
            cell.textLabel.text = @"Top sets";
        }
    }
    else if (indexPath.section == kMoreStatsSectionShows) {
        if (indexPath.row == kShowsSectionMenuItemTopShows) {
            cell.textLabel.text = @"Top shows";
        }
    }
    else if (indexPath.section == kMoreStatsSectionTours) {
        if (indexPath.row == kToursSectionMenuItemTopTours) {
            cell.textLabel.text = @"Top tours";
        }
    }
    else if (indexPath.section == kMoreStatsSectionVenues) {
        if (indexPath.row == kVenuesSectionMenuItemTopVenues) {
            cell.textLabel.text = @"Top venues";
        }
    }
    else if (indexPath.section == kMoreStatsSectionYears) {
        if (indexPath.row == kYearsSectionMenuItemTopYears) {
            cell.textLabel.text = @"Top years";
        }
        else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [[MoreStatsViewController years] objectAtIndex:(indexPath.row - kYearsSectionMenuItemStaticCount)] ];
        }
    }
    else if (indexPath.section == kMoreStatsSectionEras) {
        if (indexPath.row == kErasSectionMenuItemTopTracksfor1) {
            cell.textLabel.text = @"1.0";
        }
        else if (indexPath.row == kErasSectionMenuItemTopTracksfor2) {
            cell.textLabel.text = @"2.0";
        }
        else if (indexPath.row == kErasSectionMenuItemTopTracksfor3) {
            cell.textLabel.text = @"3.0";
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kMoreStatsSectionTracks) {
        return @"Tracks";
    }
    else if (section == kMoreStatsSectionSets) {
        return @"Sets";
    }
    else if (section == kMoreStatsSectionShows) {
        return @"Shows";
    }
    else if (section == kMoreStatsSectionTours) {
        return @"Tours";
    }
    else if (section == kMoreStatsSectionVenues) {
        return @"Venues";
    }
    else if (section == kMoreStatsSectionYears) {
        return @"Years";
    }
    else if (section == kMoreStatsSectionEras) {
        return @"Eras";
    }
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(indexPath.section == kMoreStatsSectionTracks) {
		if(indexPath.row == kTracksSectionMenuItem20Min) {
			TrackStatsViewController *c = [[TrackStatsViewController alloc] initWithTitle:@"Over 20 Min"
																			  andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTracksOver20Min]];
			[self.navigationController pushViewController:c animated:YES];
		}
    }
	else if(indexPath.section == kMoreStatsSectionSets) {
		if(indexPath.row == kSetsSectionMenuItemTopSets) {
			SetStatsViewController *c = [[SetStatsViewController alloc] initWithTitle:@"Top Sets"
                                                                        andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTopSets]];
			[self.navigationController pushViewController:c animated:YES];
		}
    }
	else if(indexPath.section == kMoreStatsSectionShows) {
		if(indexPath.row == kShowsSectionMenuItemTopShows) {
			ShowStatsViewController *c = [[ShowStatsViewController alloc] initWithTitle:@"Top Shows"
                                                                          andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTopShows]];
			[self.navigationController pushViewController:c animated:YES];
		}
    }
	else if(indexPath.section == kMoreStatsSectionTours) {
		if(indexPath.row == kToursSectionMenuItemTopTours) {
			TourStatsViewController *c = [[TourStatsViewController alloc] initWithTitle:@"Top Tours"
                                                                          andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTopTours]];
			[self.navigationController pushViewController:c animated:YES];
		}
    }
	else if(indexPath.section == kMoreStatsSectionVenues) {
		if(indexPath.row == kVenuesSectionMenuItemTopVenues) {
			VenueStatsViewController *c = [[VenueStatsViewController alloc] initWithTitle:@"Top Venues"
                                                                            andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTopVenues]];
			[self.navigationController pushViewController:c animated:YES];
		}
    }
	else if(indexPath.section == kMoreStatsSectionYears) {
		if(indexPath.row == kYearsSectionMenuItemTopYears) {
			YearStatsViewController *c = [[YearStatsViewController alloc] initWithTitle:@"Top Years"
                                                                          andStatsQuery:[StatsQueries predefinedStatQuery:kGlobalTopYears]];
			[self.navigationController pushViewController:c animated:YES];
		}
        else {
            NSNumber *year = [[MoreStatsViewController years] objectAtIndex:(indexPath.row - kYearsSectionMenuItemStaticCount)];
			TrackStatsViewController *c = [[TrackStatsViewController alloc] initWithTitle:[NSString stringWithFormat:@"Top Tracks %@", year]
                                                                            andStatsQuery:[StatsQueries topTracksInYearsQuery:@[year]]];
            
			[self.navigationController pushViewController:c animated:YES];
        }
    }
	else if(indexPath.section == kMoreStatsSectionEras) {
		if(indexPath.row == kErasSectionMenuItemTopTracksfor1) {
			TrackStatsViewController *c = [[TrackStatsViewController alloc] initWithTitle:@"Top Tracks 1.0"
                                                                            andStatsQuery:[StatsQueries topTracksForEraQuery:@"1.0"]];
            
			[self.navigationController pushViewController:c animated:YES];
        }
		if(indexPath.row == kErasSectionMenuItemTopTracksfor2) {
			TrackStatsViewController *c = [[TrackStatsViewController alloc] initWithTitle:@"Top Tracks 2.0"
                                                                            andStatsQuery:[StatsQueries topTracksForEraQuery:@"2.0"]];
            
			[self.navigationController pushViewController:c animated:YES];
        }
		else if(indexPath.row == kErasSectionMenuItemTopTracksfor3) {
			TrackStatsViewController *c = [[TrackStatsViewController alloc] initWithTitle:@"Top Tracks 3.0"
                                                                            andStatsQuery:[StatsQueries topTracksForEraQuery:@"3.0"]];
            
			[self.navigationController pushViewController:c animated:YES];
        }
    }
}

@end
