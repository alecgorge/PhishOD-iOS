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

@end

@implementation SongsViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = @"Songs";
		self.indicies = @[];
		self.songs = @[];
		
		SongsViewController *i = self;
		[self.tableView addPullToRefreshWithActionHandler:^{
			[[PhishTracksAPI sharedAPI] songs:^(NSArray *t) {
				i.songs = t;
				[i makeIndicies];
				[i.tableView reloadData];
				[i.tableView.pullToRefreshView stopAnimating];
			}
									  failure:REQUEST_FAILED(i.tableView)];
		}];
		
		[self.tableView triggerPullToRefresh];
    }
    return self;
}

- (void)makeIndicies {
    //---create the index---
    NSMutableArray *stateIndex = [[NSMutableArray alloc] init];
    
	for(PhishSong *s in self.songs) {
		char alpha = [s.title characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alpha];
		if(alpha >= 48 && alpha <= 57) {
			uniChar = @"#";
		}
		
		if(![stateIndex containsObject: uniChar])
			[stateIndex addObject: uniChar];
	}
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0f)];
	label.text = [NSString stringWithFormat:@"%d Songs", self.songs.count];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
	label.textColor = [UIColor lightGrayColor];
	
	self.tableView.tableFooterView = label;
	
	self.indicies = stateIndex;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.indicies.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return self.indicies;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
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
    
	PhishSong *song = [self filterForSection:indexPath.section][indexPath.row];
    cell.textLabel.text = song.title;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishSong *song = [self filterForSection:indexPath.section][indexPath.row];

	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	[self.navigationController pushViewController:[[SongInstancesViewController alloc] initWithSong:song]
										 animated:YES];
}

@end
