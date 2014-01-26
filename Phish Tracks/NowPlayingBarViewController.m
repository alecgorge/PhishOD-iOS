//
//  NowPlayingBarViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "NowPlayingBarViewController.h"
#import "AppDelegate.h"

#import "StreamingMusicViewController.h"
#import "PhishTracksStatsFavoritePopover.h"

@interface NowPlayingBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrevious;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonPause;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *labelTimeRemaining;

@property (nonatomic) NSDictionary *nowPlayingInfo;

@end

@implementation NowPlayingBarViewController

+ (instancetype)sharedNowPlayingBar {
    static dispatch_once_t once;
    static NowPlayingBarViewController *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] init];
	});
    return sharedFoo;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MPNowPlayingInfoCenter.defaultCenter addObserver:self
                                           forKeyPath:@"nowPlayingInfo"
                                              options:0
                                              context:NULL];
    
    self.view.backgroundColor = COLOR_PHISH_GREEN;
    self.buttonPause.backgroundColor = COLOR_PHISH_GREEN;
    self.labelTitle.textColor = COLOR_PHISH_WHITE;
    self.labelSubTitle.textColor = COLOR_PHISH_WHITE;
    self.labelTimeElapsed.textColor = COLOR_PHISH_WHITE;
    self.labelTimeRemaining.textColor = COLOR_PHISH_WHITE;
}

- (IBAction)favoriteTapped:(id)sender {
    [PhishTracksStatsFavoritePopover.sharedInstance showFromBarButtonItem:sender
                                                                   inView:self.view.superview];
}

- (BOOL)shouldShowBar {
    return ![self.labelTitle.text isEqualToString:@"NOT_LOADED"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"nowPlayingInfo"]) {
        NSDictionary *nowPlayingInfo = [change objectForKey:NSKeyValueChangeNewKey];
        self.nowPlayingInfo = nowPlayingInfo;
        
        [self updateUI];
    }
}

- (void)updateUI {
    if(!self.shouldShowBar) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect f = self.view.frame;
                             f.origin.y -= f.size.height;
                             self.view.frame = f;
                         }
                         completion:^(BOOL finished) {
                             [AppDelegate.sharedDelegate.navDelegate fixForViewController:AppDelegate.sharedDelegate.navDelegate.lastViewController];
                         }];
    }
    
    self.labelTitle.text = StreamingMusicViewController.sharedInstance.playerTitle.text;
    self.labelSubTitle.text = StreamingMusicViewController.sharedInstance.playerSubtitle.text;
    
    self.labelTimeElapsed.text = StreamingMusicViewController.sharedInstance.playerTimeElapsed.text;
    self.labelTimeRemaining.text = StreamingMusicViewController.sharedInstance.playerTimeRemaining.text;
    
    self.buttonPause.hidden = StreamingMusicViewController.sharedInstance.playerPauseButton.hidden;
    self.buttonPlay.hidden = StreamingMusicViewController.sharedInstance.playerPlayPauseButton.hidden;
    
    self.buttonPrevious.enabled = StreamingMusicViewController.sharedInstance.playerPreviousButton.enabled;
    self.buttonPrevious.alpha = StreamingMusicViewController.sharedInstance.playerPreviousButton.alpha;
    
    self.buttonNext.enabled = StreamingMusicViewController.sharedInstance.playerNextButton.enabled;
    self.buttonNext.alpha = StreamingMusicViewController.sharedInstance.playerNextButton.alpha;
}

- (IBAction)nextPressed:(id)sender {
    [StreamingMusicViewController.sharedInstance next];
}

- (IBAction)previousPressed:(id)sender {
    [StreamingMusicViewController.sharedInstance previous];
}

- (IBAction)pausePressed:(id)sender {
    [StreamingMusicViewController.sharedInstance pause];
}

- (IBAction)playPressed:(id)sender {
    [StreamingMusicViewController.sharedInstance play];
}

- (IBAction)showFullPlayer:(id)sender {
    [AppDelegate.sharedDelegate showNowPlaying];
}

- (UIImage*)maskImage:(UIImage*)image withColor:(UIColor*)color {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
	
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	return coloredImg;
}

@end
