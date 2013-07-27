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

@interface ShowViewController ()

@end

@implementation ShowViewController

@synthesize show;
@synthesize control;
@synthesize setlist;

- (id)initWithShow:(PhishShow*)s {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.show = s;
		self.title = self.show.showDate;
    }
    return self;
}

- (void)refresh:(id)sender {
	[[PhishNetAPI sharedAPI] setlistForDate:self.show.showDate
									success:^(PhishNetSetlist *s) {
										self.setlist = s;
										[self.tableView reloadData];
									}
									failure:REQUEST_FAILED(self)];
	[[PhishTracksAPI sharedAPI] fullShow:self.show
								 success:^(PhishShow *ss) {
									 self.show = ss;
									 [self.tableView reloadData];
									 
									 [super refresh:sender];
								 } failure:REQUEST_FAILED(self)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.show.hasSetsLoaded ? self.show.sets.count+1 : (self.show == nil ? 0 : 1);
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.show.hasSetsLoaded && section != 0) {
		return ((PhishSet*)self.show.sets[section-1]).tracks.count;
	}
	else if(section == 0) {
		return self.setlist == nil ? (self.show == nil ? 0 : 6) : 6;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return @"Concert Info";
	}
	return self.show.hasSetsLoaded ? ((PhishSet*)self.show.sets[section-1]).title : nil;
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		if(indexPath.row == 3) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Rating";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
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
			
			cell.textLabel.text = @"City";
			cell.detailTextLabel.text = self.show.city;
			
			return cell;
		}
		else if(indexPath.row == 2) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}

			cell.textLabel.text = @"Venue";
			cell.detailTextLabel.text = self.show.location;
			
			return cell;
		}
		else if(indexPath.row == 5) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
			if(self.setlist == nil) {
				cell.textLabel.text = @"Loading Reviews";
			}
			else {
				cell.textLabel.text = [NSString stringWithFormat:@"%d Reviews", self.setlist.reviews.count];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
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
				cell.textLabel.text = @"Loading Setlist Notes";
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
			
			if(self.show.isSoundboard && self.show.isRemastered) {
				cell.detailTextLabel.text = @"Soundboard, Remastered";
			} else if(show.isRemastered) {
				cell.detailTextLabel.text = @"Remastered";
			} else if(show.isSoundboard) {
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
	PhishSet *set = (PhishSet*)self.show.sets[indexPath.section-1];
	PhishSong *track = (PhishSong*)set.tracks[indexPath.row];

	[self.navigationController pushViewController:[[SongInstancesViewController alloc] initWithSong:track]
										 animated:YES];	
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0) {
		if(indexPath.row == 5) {
			ReviewsViewController *rev = [[ReviewsViewController alloc] initWithSetlist:self.setlist];
			[self.navigationController pushViewController:rev
												 animated:YES];
		}
		else if(indexPath.row == 4) {
			ConcertInfoViewController *info = [[ConcertInfoViewController alloc] initWithSetlist:self.setlist];
			[self.navigationController pushViewController:info
												 animated:YES];
		}
		
		return;
	}
	
	((AppDelegate*)[UIApplication sharedApplication].delegate).shouldShowNowPlaying = YES;
	StreamingMusicViewController *newPlayer = [StreamingMusicViewController sharedInstance];
	
	NSMutableArray *playlist = [NSMutableArray array];

	PhishSet *set = (PhishSet*)self.show.sets[indexPath.section-1];
	PhishSong *track = (PhishSong*)set.tracks[indexPath.row];

	int count = 0, startIndex = 0;
	for(PhishSet *set in self.show.sets) {
		for(PhishSong *song in set.tracks) {
			if(song.trackId == track.trackId) {
				startIndex = count;
			}
			
			StreamingPlaylistItem *item = [[StreamingPlaylistItem alloc] initWithSong:song
																			 fromShow:self.show];
			
			[playlist addObject: item];
			
			count++;
		}
	}
	
	[newPlayer changePlaylist:playlist
			andStartFromIndex:startIndex];

	
	[((AppDelegate *)[UIApplication sharedApplication].delegate) navigationController:self.navigationController
															   willShowViewController:self
																			 animated:YES];

	[((AppDelegate *)[UIApplication sharedApplication].delegate) showNowPlaying];
	
//	NowPlayingViewController *player = [NowPlayingViewController sharedInstance];
//	
//	dispatch_async(dispatch_get_main_queue(), ^{
//		PhishSet *set = (PhishSet*)self.show.sets[indexPath.section-1];
//		PhishSong *track = (PhishSong*)set.tracks[indexPath.row];
//		
//		int count = 0;
//		for(PhishSet *set in self.show.sets) {
//			for(PhishSong *song in set.tracks) {
//				if(song.trackId == track.trackId) {
//					goto exit_loop;
//				}
//				count++;
//			}
//		}
//		exit_loop:;
//		
//		[PhishTrackProvider sharedInstance].show = self.show;
//		[player reloadData];
//		
//		[player playTrack:count
//			   atPosition:0
//				   volume:player.volume];
//		
//		[player performSelector:@selector(updateUIForCurrentTrack)];
//		player.volume = MPMusicPlayerController.iPodMusicPlayer.volume;
//		[player performSelector:@selector(adjustPlayButtonState)];
//	});
//	
//	[((AppDelegate *)[UIApplication sharedApplication].delegate) navigationController:self.navigationController
//															   willShowViewController:self
//																			 animated:YES];
//	
//	[self.navigationController presentModalViewController:player
//												 animated:YES];
}

@end
