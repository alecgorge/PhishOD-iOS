//
//  SongsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SongsViewController.h"
#import "SongInstancesViewController.h"

@interface SongsViewController ()

@property (nonatomic) UISearchDisplayController *con;

@end

@implementation SongsViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = @"Songs";
		self.indicies = @[];
		self.songs = @[];
		[self createSearchBar];
    }
    return self;
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] songs:^(NSArray *t) {
		self.songs = t;
		[self makeIndicies];
		[self.tableView reloadData];
		[super refresh:sender];
	}
						  failure:REQUEST_FAILED(self.tableView)];
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
	self.results = [self.songs select:^BOOL(id object) {
		PhishinSong *song = (PhishinSong*)object;
		
		return [song.title rangeOfString:src
								 options:NSCaseInsensitiveSearch].location != NSNotFound;
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

- (void)makeIndicies {
    //---create the index---
    NSMutableArray *stateIndex = [[NSMutableArray alloc] init];
    
	for(PhishinTrack *s in self.songs) {
		char alpha = [s.title characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alpha];
		if(alpha >= 48 && alpha <= 57) {
			uniChar = @"#";
		}
		
		if(![stateIndex containsObject: uniChar])
			[stateIndex addObject: uniChar];
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0f)];
	label.text = [NSString stringWithFormat:@"%lu Songs", (unsigned long)self.songs.count];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
	label.textColor = [UIColor lightGrayColor];
	
	self.tableView.tableFooterView = label;
	
	self.indicies = stateIndex;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title beginswith[c] %@", alphabet];
	if([alphabet isEqualToString:@"#"]) {
		predicate = [NSPredicate predicateWithFormat:@"SELF.title MATCHES '^[0-9].*'"];
	}
    NSArray *songs = [self.songs filteredArrayUsingPredicate:predicate];
	return songs;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		return self.results.count;
	}
	return [self filterForSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
    
	PhishinSong *song;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		song = self.results[indexPath.row];
	}
	else {
		song = [self filterForSection:indexPath.section][indexPath.row];;
	}
    cell.textLabel.text = song.title;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

-(void)dealloc {
	self.con = nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishinSong *song;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
		song = self.results[indexPath.row];
	}
	else {
		song = [self filterForSection:indexPath.section][indexPath.row];;
	}
	
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	[self.navigationController pushViewController:[[SongInstancesViewController alloc] initWithSong:song]
										 animated:YES];
}

@end
