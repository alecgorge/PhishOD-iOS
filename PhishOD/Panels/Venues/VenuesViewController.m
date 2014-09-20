//
//  VenuesViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "VenuesViewController.h"
#import "VenueViewController.h"
#import <TDBadgedCell/TDBadgedCell.h>

@interface VenuesViewController ()

@property (nonatomic) UISearchDisplayController *con;

@end

@implementation VenuesViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = @"Venues";
		self.indicies = @[];
		self.venues = @[];
		
		[self createSearchBar];
    }
    return self;
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] venues:^(NSArray *t) {
		self.venues = t;
		[self makeIndicies];
		[self.tableView reloadData];
		[super refresh:sender];
	}
						  failure:REQUEST_FAILED(self.tableView)];
}

- (void)makeIndicies {
    //---create the index---
    NSMutableArray *stateIndex = [[NSMutableArray alloc] init];
    
	for(PhishinVenue *s in self.venues) {
		char alpha = [[s.name uppercaseString] characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alpha];
		if(alpha >= 48 && alpha <= 57) {
			uniChar = @"#";
		}
		
		if(![stateIndex containsObject: uniChar])
			[stateIndex addObject: uniChar];
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0f)];
	label.text = [NSString stringWithFormat:@"%lu Venues", (unsigned long)self.venues.count];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
	label.textColor = [UIColor lightGrayColor];
	
	self.tableView.tableFooterView = label;
	
	self.indicies = stateIndex;
}

- (void)createSearchBar {
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
	
	self.con = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
												 contentsController:self];
	
	self.searchDisplayController.searchResultsDelegate = self;
	self.searchDisplayController.searchResultsDataSource = self;
	self.searchDisplayController.delegate = self;
	
	self.tableView.tableHeaderView = searchBar;
}

- (void)updateFilteredContentForProductName {
	NSString *src = self.con.searchBar.text;
	self.results = [self.venues select:^BOOL(id object) {
		PhishinVenue *ven = (PhishinVenue*)object;
		
		BOOL name = [ven.name rangeOfString:src
									options:NSCaseInsensitiveSearch].location != NSNotFound;
		BOOL loc = [ven.location rangeOfString:src
									   options:NSCaseInsensitiveSearch].location != NSNotFound;
		BOOL past = [ven.past_names rangeOfString:src
										  options:NSCaseInsensitiveSearch].location != NSNotFound;
		
		
		return name || loc || past;
	}];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForProductName];
	
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self updateFilteredContentForProductName];
	
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return 1;
	}
	return self.indicies.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return nil;
	}
	return self.indicies;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return nil;
	}

	if(section == 0) {
		return @"123";
	}
	return self.indicies[section];
}

- (NSArray *)filterForSection:(NSUInteger) section {
    NSString *alphabet = self.indicies[section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", alphabet];
	if([alphabet isEqualToString:@"#"]) {
		predicate = [NSPredicate predicateWithFormat:@"SELF.name MATCHES '^[0-9].*'"];
	}
    NSArray *songs = [self.venues filteredArrayUsingPredicate:predicate];
	return songs;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return self.results.count;
	}
	return [self filterForSection:section].count;
}

-(void)dealloc {
	self.con = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
								   reuseIdentifier:CellIdentifier];
	}
    
	PhishinVenue *venue;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		venue = self.results[indexPath.row];
	}
	else {
		venue = [self filterForSection:indexPath.section][indexPath.row];
	}

    cell.textLabel.text = venue.name;
	cell.detailTextLabel.text = venue.location;
	
	cell.badgeString = [NSString stringWithFormat:@"%d", venue.shows_count];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];

	PhishinVenue *venue;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		venue = self.results[indexPath.row];
	}
	else {
		venue = [self filterForSection:indexPath.section][indexPath.row];
	}

	[self.navigationController pushViewController:[[VenueViewController alloc] initWithVenue:venue]
										 animated:YES];
}

@end
