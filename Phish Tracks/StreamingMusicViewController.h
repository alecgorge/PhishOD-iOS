//
//  StreamingMusicViewController.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/6/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "StreamingPlaylistItem.h"

@interface StreamingMusicViewController : UIViewController

+ (StreamingMusicViewController*)sharedInstance;

- (id)initWithPlaylist:(NSArray*)playlist atIndex:(NSInteger)index;

@property NSArray *playlist;
@property BOOL isPlaying;
@property MPMoviePlayerController *player;
@property (readonly) StreamingPlaylistItem *currentItem;
@property (nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel  *playerTitle;
@property (weak, nonatomic) IBOutlet UILabel  *playerSubtitle;
@property (weak, nonatomic) IBOutlet UIButton *playerPlayPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playerNextButton;
@property (weak, nonatomic) IBOutlet UIButton *playerPreviousButton;
@property (weak, nonatomic) IBOutlet UILabel  *playerTimeRemaining;
@property (weak, nonatomic) IBOutlet UILabel  *playerTimeElapsed;
@property (weak, nonatomic) IBOutlet UISlider *playerScrubber;
@property (weak, nonatomic) IBOutlet UILabel *playerStatus;
@property (weak, nonatomic) IBOutlet UIButton *playerPauseButton;
@property (weak, nonatomic) IBOutlet MPVolumeView *playerAirPlayButton;

@property (strong) UIButton *mpAirPlayButton;

- (IBAction)playerPlayPauseTapped:(id)sender;
- (IBAction)playerNextTapped:(id)sender;
- (IBAction)playerPreviousTapped:(id)sender;
- (IBAction)playerProgressScrubbed:(id)sender;

- (void)play;
- (void)pause;
- (void)next;
- (void)previous;
- (void)playPauseToggle;

- (void)changePlaylist:(NSArray*)array andStartFromIndex:(NSInteger)index;

- (IBAction)postionBeginAdjustment:(id)sender;
- (IBAction)positionEndAdjustment:(id)sender;

@end
