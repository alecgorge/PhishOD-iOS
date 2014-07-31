//
//  ShowViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "ShowViewController.h"

#import <SVWebViewController/SVWebViewController.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>

#import "AppDelegate.h"
#import "SongInstancesViewController.h"
#import "AGMediaPlayerViewController.h"
#import "VenueViewController.h"
#import "PhishinMediaItem.h"
#import "PHODTrackCell.h"

#import "PhishTracksStatsFavoritePopover.h"


@interface ShowViewController ()

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;

@end

@implementation ShowViewController

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

- (id)initWithShowDate:(NSString *)showDate
{
	PhishinShow *__show = [[PhishinShow alloc] init];
	__show.date = showDate;
	return [self initWithShow:__show];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupRightBarButtonItem];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"track"];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [self.tableView reloadData];
                                                                }];
    
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
                                                        withPhishinObject:self.show];
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
								 
								 if(self.show.missing) {
									 UIAlertView *a = [UIAlertView.alloc initWithTitle:@"Recording Missing"
																			   message:@"Unfortunately, we don't have a recording for this show :(. If you think you have a recording that should be up here please contact phish.in.music@gmail.com"
																			  delegate:nil
																	 cancelButtonTitle:@"OK :("
																	 otherButtonTitles:nil];
									 
									 [a show];
								 }
								 
								 [super refresh:sender];
								 [self performAutoplayIfNecessary];
							 } failure:REQUEST_FAILED(self.tableView)];
}

- (void)performAutoplayIfNecessary {
	if(self.autoplay && self.show.tracks) {
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
	if(AGMediaPlayerViewController.sharedInstance.progress > 0) {
		AGMediaPlayerViewController.sharedInstance.progress = self.autoplaySeekLocation / AGMediaPlayerViewController.sharedInstance.duration;
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
		return ((PhishinSet*)self.show.sets[section-1]).tracks.count;
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
	return self.show.sets.count > 0 ? ((PhishinSet*)self.show.sets[section-1]).title : nil;
}

- (NSString*)formattedStringForDuration:(NSTimeInterval)duration {
    NSInteger minutes = floor(duration/60);
    NSInteger seconds = round(duration - minutes * 60);
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
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
				cell.textLabel.text = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)self.setlist.reviews.count];
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
		else if(indexPath.row == 5) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
            cell.textLabel.text = @"Taper Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
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
			} else if(self.show.remastered) {
				cell.detailTextLabel.text = @"Remastered";
			} else if(self.show.sbd) {
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
	
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"
                                                          forIndexPath:indexPath];
	
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section-1];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
    
    [cell updateCellWithTrack:track
                  inTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    }
    
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"track"];
	PhishinSet *set = (PhishinSet*)self.show.sets[indexPath.section-1];
	PhishinTrack *track = (PhishinTrack*)set.tracks[indexPath.row];
    
    return [cell heightForCellWithTrack:track
                            inTableView:tableView];
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
		if(indexPath.row == 5) {
            NSString *url = [NSString stringWithFormat:@"http://phish-taper-info.app.alecgorge.com/notes/%@.txt", self.show.date];
			SVWebViewController *vc = [SVWebViewController.alloc initWithAddress:url];
			[self.navigationController pushViewController:vc
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
	NSArray *playlist = [self.show.tracks map:^id(id object) {
		return [PhishinMediaItem.alloc initWithTrack:object];
	}];
	
	NSInteger startIndex = [self.show.tracks indexOfObjectPassingTest:^BOOL(PhishinTrack *obj, NSUInteger idx, BOOL *stop) {
		return track.id == [obj id];
	}];
	
	[AppDelegate sharedDelegate].currentlyPlayingShow = self.show;
	
    if(!AGMediaPlayerViewController.sharedInstance.playbackQueue
	|| AGMediaPlayerViewController.sharedInstance.playbackQueue.count == 0) {
        [AppDelegate.sharedDelegate presentMusicPlayer];
    }

    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:startIndex];
}

@end
