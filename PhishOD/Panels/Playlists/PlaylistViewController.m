//
//  PlaylistViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/6/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PlaylistViewController.h"

#import <CSNNotificationObserver/CSNNotificationObserver.h>

#import "IGDurationHelper.h"
#import "PHODTrackCell.h"
#import "PhishinMediaItem.h"
#import "AGMediaPlayerViewController.h"
#import "NowPlayingBarViewController.h"
#import "AppDelegate.h"

@interface PlaylistViewController ()

@property (nonatomic, strong) CSNNotificationObserver *trackChangedEvent;

@end

@implementation PlaylistViewController

- (instancetype)initWithPlaylistStub:(PhishinPlaylistStub *)stub {
    if (self = [super init]) {
        self.stub = stub;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.stub.name;

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"cell"];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                         target:self
                                                                                         action:@selector(share)];
    
    self.trackChangedEvent = [[CSNNotificationObserver alloc] initWithName:@"AGMediaItemStateChanged"
                                                                    object:nil queue:NSOperationQueue.mainQueue
                                                                usingBlock:^(NSNotification *notification) {
                                                                    [self.tableView reloadData];
                                                                }];

}

- (void)share {
    NSString *text = [NSString stringWithFormat:@"%@ by %@", self.stub.name, self.stub.phishinAuthor];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://phish.in/play/%@", self.stub.phishinSlug]];
    
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[text, url]
																			 applicationActivities:nil];
    
	activityVC.excludedActivityTypes = [[NSArray alloc] initWithObjects: UIActivityTypePostToWeibo, nil];
    
	[self.navigationController presentViewController:activityVC
											animated:YES
										  completion:nil];
}

- (void)refresh:(id)sender {
    [PhishinAPI.sharedAPI playlistForSlug:self.stub.phishinSlug
                                  success:^(PhishinPlaylist *playlist) {
                                      self.playlist = playlist;
                                      
                                      self.title = playlist.name;
                                      
                                      [self.tableView reloadData];
                                      [super refresh:sender];
                                  }
                                  failure:REQUEST_FAILED(self.tableView)];
}

- (PhishinTrack *)trackForIndexPath:(NSIndexPath *)indexPath {
    return self.playlist.tracks[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.playlist != nil;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.playlist.tracks.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ in %@ tracks", [IGDurationHelper formattedTimeWithInterval:self.playlist.duration], @(self.playlist.tracks.count)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                          forIndexPath:indexPath];
    
    PhishinTrack *track = [self trackForIndexPath:indexPath];
    
    [cell updateCellWithTrack:track
                  inTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    PhishinTrack *track = [self trackForIndexPath:indexPath];
    
    return [cell heightForCellWithTrack:track
                            inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    NSArray *tracks = self.playlist.tracks;
	
    PhishinTrack *track = [self trackForIndexPath:indexPath];
	NSArray *playlist = [tracks map:^id(PhishinTrack *object) {
		return [PhishinMediaItem.alloc initWithTrack:object
											  inShow:object.show];
	}];
	
	NSInteger startIndex = [tracks indexOfObjectPassingTest:^BOOL(PhishinTrack *obj, NSUInteger idx, BOOL *stop) {
		return track.id == [obj id];
	}];
	
	[AppDelegate sharedDelegate].currentlyPlayingShow = track.show;
	
    if(!NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        [AppDelegate.sharedDelegate presentMusicPlayer];
    }
    
    [AGMediaPlayerViewController.sharedInstance replaceQueueWithItems:playlist
                                                           startIndex:startIndex];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
}

@end
