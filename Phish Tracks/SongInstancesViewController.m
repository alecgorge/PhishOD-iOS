//
//  SongInstancesViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "SongInstancesViewController.h"
#import <TDBadgedCell/TDBadgedCell.h>
#import "ShowViewController.h"
#import <SVWebViewController/SVWebViewController.h>

@interface SongInstancesViewController ()

@end

@implementation SongInstancesViewController

- (id)initWithSong:(PhishSong*) s {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        self.title = s.title;
		self.song = s;
		self.indicies = @[];
		
		SongInstancesViewController *i = self;
		[self.tableView addPullToRefreshWithActionHandler:^{
			[[PhishTracksAPI sharedAPI] fullSong:s
										 success:^(PhishSong *ss) {
				i.song = ss;
				i.title = [NSString stringWithFormat:@"%@ (%d)", ss.title, ss.tracks.count];
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
    
	for(PhishSong *s in self.song.tracks) {
        NSString *uniChar = [s.showDate substringWithRange:NSMakeRange(0, 4)];
		
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.showDate beginswith[c] %@", alphabet];
    return [self.song.tracks filteredArrayUsingPredicate:predicate];
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return self.indicies;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.indicies.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 2;
	}
	return [self filteredForSection: section].count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Song Info";
	}
	else {
		NSArray *yearInst = [self filteredForSection:section];
		if(self.song.tracks.count) {
			return [NSString stringWithFormat:@"%@ - %d Times Played", self.indicies[section - 1], yearInst.count];
		}
		return @"Times Played";
	}
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
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
		else {
			cell.textLabel.text = @"Song Lyrics";
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
    
    static NSString *CellIdentifier = @"BadgedCell";
    TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
								   reuseIdentifier:CellIdentifier];
	}
	
	PhishSong *song = [self filteredForSection:indexPath.section][indexPath.row];
    cell.textLabel.text = song.showDate;
	cell.detailTextLabel.text = song.showLocation;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.badgeString = [self formattedStringForDuration:song.duration];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return UITableViewAutomaticDimension;
	}
	return tableView.rowHeight * 1.3;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		if(indexPath.row == 0) {
			NSString *addr = [NSString stringWithFormat:@"http://phish.net/song/%@/history", self.song.slug];
			[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:addr]
												 animated:YES];
			
		}
		else {
			NSString *addr = [NSString stringWithFormat:@"http://phish.net/song/%@/lyrics", self.song.slug];
			[self.navigationController pushViewController:[[SVWebViewController alloc] initWithAddress:addr]
												 animated:YES];
		}
		return;
	}
	
	PhishSong *song = [self filteredForSection:indexPath.section][indexPath.row];
	
	PhishShow *show = [[PhishShow alloc] init];
	show.showDate = song.showDate;
	
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	[self.navigationController pushViewController:[[ShowViewController alloc] initWithShow:show]
										 animated:YES];
}

@end
