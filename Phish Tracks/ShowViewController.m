//
//  ShowViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ShowViewController.h"
#import <TDBadgedCell/TDBadgedCell.h>
#import "AppDelegate.h"
#import "SongInstancesViewController.h"
#import "StreamingMusicViewController.h"
#import "VenueViewController.h"

@interface ShowViewController ()

@end

@implementation ShowViewController

@synthesize show;
@synthesize control;
@synthesize setlist;

- (id)initWithShow:(PhishinShow*)s {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.show = s;
		self.title = self.show.date;
		
		self.autoplay = NO;
		self.autoplaySeekLocation = 0.0;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupRightBarButtonItem];
}

- (void)setupRightBarButtonItem {
	if([AppDelegate sharedDelegate].currentlyPlayingShow != nil) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player"
																				  style:UIBarButtonItemStyleDone
																				 target:[AppDelegate sharedDelegate]
																				 action:@selector(nowPlaying)];
	}
}

- (void)refresh:(id)sender {
	self.setlist = nil;
	[[PhishNetAPI sharedAPI] setlistForDate:self.show.date
									success:^(PhishNetSetlist *s) {
										self.setlist = s;
										[self.tableView reloadData];
									}
									failure:REQUEST_FAILED(self.tableView)];
	[[PhishinAPI sharedAPI] fullShow:self.show
							 success:^(PhishinShow *ss) {
								 self.show = ss;
								 [self.tableView reloadData];
								 
								 [super refresh:sender];
								 
								 [self performAutoplayIfNecessary];
							 } failure:REQUEST_FAILED(self.tableView)];
}

- (void)performAutoplayIfNecessary {
	if(self.autoplay) {
		NSArray *matchingTracks = [self.show.tracks reject:^BOOL(PhishinTrack *object) {
			return !(object.id == self.autoplayTrackId);
		}];
		
		if(matchingTracks.count > 0) {
			PhishinTrack *track = matchingTracks[0];
			
			[self playTrack:track];

			if(self.autoplaySeekLocation > 0) {
				[self performSelector:@selector(autoplaySeek)
						   withObject:nil
						   afterDelay:0.25];
			}
		}
		
		self.autoplay = NO;
	}
}

- (void)autoplaySeek {
	if([StreamingMusicViewController sharedInstance].currentProgress > 0) {
		[[StreamingMusicViewController sharedInstance] seekTo:self.autoplaySeekLocation];
	}
	else {
		[self performSelector:@selector(autoplaySeek)
				   withObject:nil
				   afterDelay:0.25];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.show.sets.count+1;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.show.sets.count > 0 && section != 0) {
		return ((PhishSet*)self.show.sets[section-1]).tracks.count;
	}
	else if(section == 0) {
		return self.setlist == nil ? (self.show == nil ? 0 : 5) : 5;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Concert Info";
	}
	return self.show.sets.count > 0 ? ((PhishinSet*)self.show.sets[section-1]).title : nil;
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		if(indexPath.row == 2) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Rating";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			if(self.setlist == nil) {
				cell.detailTextLabel.text = @"Loading...";
			}
			else {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/5.00 (%@ ratings)", self.setlist.rating, self.setlist.ratingCount];
			}
			
			return cell;
		}
		else if(indexPath.row == 1) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}

			cell.textLabel.text = @"Venue";
			cell.detailTextLabel.text = self.show.venue.name;
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
		else if(indexPath.row == 4) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
			if(self.setlist == nil) {
				cell.textLabel.text = @"Loading Reviews";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else {
				cell.textLabel.text = [NSString stringWithFormat:@"%d Reviews", self.setlist.reviews.count];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			return cell;
		}
		else if(indexPath.row == 3) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
			if(self.setlist == nil) {
				cell.textLabel.text = @"Loading Setlist Notes";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else {
				cell.textLabel.text = @"Setlist Notes";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}

			return cell;
		}
		else if(indexPath.row == 0 && self.show != nil) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Features";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			if(self.show.sbd && self.show.remastered) {
				cell.detailTextLabel.text = @"Soundboard, Remastered";
			} else if(show.remastered) {
				cell.detailTextLabel.text = @"Remastered";
			} else if(show.sbd) {
				cell.detailTextLabel.text = @"Soundboard";
			} else {
				cell.detailTextLabel.text = @"None";
			}
			
			return cell;
		}
	}
	else if(indexPath.section == 0 && self.setlist == nil) {
		return [[UITableViewCell alloc] init];
	}
	
    static NSString *CellIdentifier = @"MusicCell";
    TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(cell == nil) {
		cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleValue1
								   reuseIdentifier:CellIdentifier];
	}
	
	PhishSet *set = (PhishSet*)self.show.sets[indexPath.section-1];
	PhishSong *track = (PhishSong*)set.tracks[indexPath.row];
	cell.textLabel.text = track.title;
	cell.textLabel.numberOfLines = 2;
	cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
	cell.textLabel.font = [UIFont boldSystemFontOfSize: 14.0];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
	cell.detailTextLabel.text = [self formattedStringForDuration: track.duration];
	
//	if(self.show.isSoundboard && self.show.isRemastered) {
//		cell.badgeString = @"SDB+REMAST";
//		cell.badgeColor = [UIColor darkGrayColor];
//	} else if(self.show.isRemastered) {
//		cell.badgeString = @"REMAST";
//		cell.badgeColor = [UIColor blueColor];
//	} else if(self.show.isSoundboard) {
//		cell.badgeString = @"SBD";
//		cell.badgeColor = [UIColor redColor];
//	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section-1];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
	PhishinSong *song = [[PhishinSong alloc] init];
	song.id = [track.song_ids[0] integerValue];
	
	[self.navigationController pushViewController:[[SongInstancesViewController alloc] initWithSong:song]
										 animated:YES];	
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0) {
		if(indexPath.row == 4) {
			ReviewsViewController *rev = [[ReviewsViewController alloc] initWithSetlist:self.setlist];
			[self.navigationController pushViewController:rev
												 animated:YES];
		}
		else if(indexPath.row == 3) {
			ConcertInfoViewController *info = [[ConcertInfoViewController alloc] initWithSetlist:self.setlist];
			[self.navigationController pushViewController:info
												 animated:YES];
		}
		else if(indexPath.row == 1) {
			VenueViewController *vc = [[VenueViewController alloc] initWithVenue:self.show.venue];
			[self.navigationController pushViewController:vc
												 animated:YES];
		}
		
		return;
	}
	
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section-1];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
	
	[self playTrack:track];
}

- (void)playTrack:(PhishinTrack *)track {
	[AppDelegate sharedDelegate].shouldShowNowPlaying = YES;
	StreamingMusicViewController *newPlayer = [StreamingMusicViewController sharedInstance];
	
	NSArray *playlist = [self.show.tracks map:^id(id object) {
		return [[PhishinStreamingPlaylistItem alloc] initWithTrack:object];
	}];
	
	int startIndex = [self.show.tracks indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return track.id == [obj id];
	}];
	
	[newPlayer changePlaylist:playlist
			andStartFromIndex:startIndex];
	
	[[AppDelegate sharedDelegate] showNowPlaying];
	[AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
	
	[self setupRightBarButtonItem];
}

@end
