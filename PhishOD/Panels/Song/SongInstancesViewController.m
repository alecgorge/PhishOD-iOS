//
//  SongInstancesViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SongInstancesViewController.h"
#import "ShowViewController.h"
#import <SVWebViewController/SVWebViewController.h>

#import "JamChartEntryViewController.h"

@interface SongInstancesViewController ()

@property (nonatomic, readonly) NSArray *filteredSongs;

@end

@implementation SongInstancesViewController

- (id)initWithSong:(PhishinSong*) s {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = s.title;
		self.song = s;
		self.indicies = @[];
		
		NSArray *itemArray = @[@"All", @"Key", @"Notable", @"Charted"];
        control = [[UISegmentedControl alloc] initWithItems:itemArray];
        control.frame = CGRectMake(0, 10.0, self.tableView.bounds.size.width - 20, 30.0);
		control.selectedSegmentIndex = 0;
		[control addTarget:self
					action:@selector(doFilterSongs)
		  forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (NSArray *)doFilterSongs {
	if(control.selectedSegmentIndex == 0) {
		filteredSongs = self.song.tracks;
	}
	else if(control.selectedSegmentIndex == 1) {
		NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(PhishinTrack *t, NSDictionary *bindings) {
			return t.jamChartEntry != nil && t.jamChartEntry.isKey;
		}];
		filteredSongs = [self.song.tracks filteredArrayUsingPredicate:pred];
	}
	else if(control.selectedSegmentIndex == 2) {
		NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(PhishinTrack *t, NSDictionary *bindings) {
			return t.jamChartEntry != nil && t.jamChartEntry.isNoteworthy;
		}];
		filteredSongs = [self.song.tracks filteredArrayUsingPredicate:pred];
	}
	else if(control.selectedSegmentIndex == 3) {
		NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(PhishinTrack *t, NSDictionary *bindings) {
			return t.jamChartEntry != nil;
		}];
		filteredSongs = [self.song.tracks filteredArrayUsingPredicate:pred];
	}
	else {
		filteredSongs = self.song.tracks;
	}
	
	[self.tableView reloadData];
	
	return filteredSongs;
}

- (NSArray *)filteredSongs {
	if(filteredSongs != nil) {
		return filteredSongs;
	}
	else {
		return [self doFilterSongs];
	}
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] fullSong:self.song
							 success:^(PhishinSong *ss) {
								 self.song = ss;
								 
								 [self makeIndicies];
								 
								 [[PhishNetAPI sharedAPI] jamsForSong:self.song
															  success:^(NSArray *jamCharts) {
																  for (PhishNetJamChartEntry *e in jamCharts) {
																	  PhishinTrack *track = [self.song.tracks detect:^BOOL(PhishinTrack *object) {
																		  return [object.date isEqualToDate:e.date];
																	  }];
																	  
																	  if(track) {
																		  track.jamChartEntry = e;
																	  }
																  }
																  
																  [self.tableView reloadData];
																  
																  [super refresh:sender];
															  }];
							 }
							 failure:REQUEST_FAILED(self.tableView)];
}

- (void)makeIndicies {
    //---create the index---
    NSMutableArray *stateIndex = [[NSMutableArray alloc] init];
    
	for(PhishinTrack *s in self.song.tracks) {
        NSString *uniChar = s.index;
		
		if(![stateIndex containsObject: uniChar])
			[stateIndex addObject: uniChar];
	}
	
	self.indicies = stateIndex;
}

- (NSArray *)filteredForSection:(NSUInteger) section {
	if(self.indicies.count == 0) {
		return @[];
	}
    NSString *alphabet = self.indicies[section-1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.index == %@", alphabet];
    return [self.filteredSongs filteredArrayUsingPredicate:predicate];
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	if(self.indicies.count <= 5) return nil;
	return self.indicies;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.indicies.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if(section == self.indicies.count && self.song.tracks.count > 15) {
		return [NSString stringWithFormat:@"%lu times", (unsigned long)self.song.tracks.count];
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 3;
	}
	return [self filteredForSection: section].count;
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
	return 22.0f;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Song Info";
	}
	else {
		if(self.song.tracks.count) {
			return self.indicies[section - 1];
		}
		return @"Times Played";
	}
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if(cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:CellIdentifier];
		}

		if(indexPath.row == 0) {
			cell.textLabel.text = @"Song History";
		}
		else if(indexPath.row == 1) {
			cell.textLabel.text = @"Song Lyrics";
		}
		else if(indexPath.row == 2) {
			cell.textLabel.text = @"Complete Jamming Charts";
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
    
    static NSString *CellIdentifier = @"BadgedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									  reuseIdentifier:CellIdentifier];
	}
	
	PhishinTrack *song = [self filteredForSection:indexPath.section][indexPath.row];
    cell.textLabel.text = song.show_date;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
	cell.detailTextLabel.textColor = [UIColor grayColor];
	
	if(song.jamChartEntry) {
		NSString *type = @"Jam Chart";
		
		if(song.jamChartEntry.isKey) {
			type = @"Key Jam";
		}
		else if(song.jamChartEntry.isNoteworthy) {
			type = @"Noteworthy Jam";
		}
		
		cell.detailTextLabel.text = [NSString stringWithFormat: @"%@, %@", type, [self formattedStringForDuration: song.duration], nil];
	}
	else {
		cell.detailTextLabel.text = [self formattedStringForDuration:song.duration];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewAutomaticDimension;

	if(indexPath.section == 0) {
		return UITableViewAutomaticDimension;
	}
	return tableView.rowHeight * 1.5;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0) {
		if(indexPath.row == 0) {
			NSString *addr = [NSString stringWithFormat:@"http://phish.net/song/%@/history", self.song.netSlug];
			[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:addr]
												 animated:YES];
			
		}
		else if(indexPath.row == 1) {
			NSString *addr = [NSString stringWithFormat:@"http://phish.net/song/%@/lyrics", self.song.netSlug];
			[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:addr]
												 animated:YES];
		}
		else if(indexPath.row == 2) {
			NSString *addr = [NSString stringWithFormat:@"http://phish.net/jamcharts/song/%@", self.song.netSlug];
			[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:addr]
												 animated:YES];
		}
		return;
	}
	
	PhishinTrack *song = [self filteredForSection:indexPath.section][indexPath.row];
	
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(song.jamChartEntry) {
		JamChartEntryViewController *vc = [JamChartEntryViewController.alloc initWithJamChartEntry:song.jamChartEntry
																						  andTrack:song];
		
		[self.navigationController pushViewController:vc
											 animated:YES];
	}
	else {
		PhishinShow *show = [[PhishinShow alloc] init];
		show.id = (int)song.show_id;
		show.date = song.show_date;
		
		ShowViewController *showvc = [ShowViewController.alloc initWithShow:show];
		showvc.autoplay = YES;
		showvc.autoplayTrackId = song.id;
		
		[self.navigationController pushViewController:showvc
											 animated:YES];
	}
}

@end
