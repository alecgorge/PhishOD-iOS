//
//  NowPlayingBarViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <MarqueeLabel/MarqueeLabel.h>

#import "NowPlayingBarViewController.h"
#import "AppDelegate.h"

#import "AGMediaPlayerViewController.h"
#import "PhishTracksStatsFavoritePopover.h"
#import "IGDurationHelper.h"
#import "PhishinMediaItem.h"

@interface NowPlayingBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UIButton *buttonPause;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelTitle;
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelSubTitle;
@property (weak, nonatomic) IBOutlet UIProgressView *progressIndicator;

@property (nonatomic) NSDictionary *nowPlayingInfo;

@property (nonatomic) BOOL hasChanged;

@end

@implementation NowPlayingBarViewController

+ (instancetype)sharedInstance {
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
    self.labelTitle.textColor = COLOR_PHISH_WHITE;
    self.labelSubTitle.textColor = COLOR_PHISH_WHITE;
    
    self.labelTitle.fadeLength =
    self.labelSubTitle.fadeLength = 10.0f;
    
    self.labelTitle.marqueeType =
    self.labelSubTitle.marqueeType = MLContinuous;
    
    self.labelTitle.animationDelay =
    self.labelSubTitle.animationDelay = 6.0f;
    
    self.labelTitle.rate =
    self.labelSubTitle.rate = 20.0f;
    
    self.progressIndicator.backgroundColor = COLOR_PHISH_GREEN;
    self.progressIndicator.tintColor = COLOR_PHISH_LIGHT_GREEN;
    self.progressIndicator.progressTintColor = COLOR_PHISH_WHITE;
}

- (IBAction)favoriteTapped:(id)sender {
    id<AGAudioItem> item = AGMediaPlayerViewController.sharedInstance.currentItem;
    
    PhishinMediaItem *pi = (PhishinMediaItem *)item;
    
    [PhishTracksStatsFavoritePopover.sharedInstance showFromBarButtonItem:sender
                                                                   inView:self.view.superview
                                                        withPhishinObject:pi.phishinTrack];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if([keyPath isEqualToString:@"nowPlayingInfo"]) {
        self.hasChanged = YES;
        
        NSDictionary *nowPlayingInfo = [change objectForKey:NSKeyValueChangeNewKey];
        self.nowPlayingInfo = nowPlayingInfo;
        
        [self updateUI];
    }
}

- (void)updateUI {
    NSString *newTitle = AGMediaPlayerViewController.sharedInstance.currentItem.title;
    NSString *newSubTitle = AGMediaPlayerViewController.sharedInstance.currentItem.album;
    
    if(![self.labelTitle.text isEqualToString:newTitle]) {
        self.labelTitle.text = newTitle;
        [self.labelTitle restartLabel];
    }
    
    if(![self.labelSubTitle.text isEqualToString:newSubTitle]) {
        self.labelSubTitle.text = newSubTitle;
        [self.labelSubTitle restartLabel];
    }
    
    self.buttonPause.hidden = !AGMediaPlayerViewController.sharedInstance.playing;
    self.buttonPlay.hidden = AGMediaPlayerViewController.sharedInstance.playing;
    
    [self.progressIndicator setProgress:AGMediaPlayerViewController.sharedInstance.progress
                               animated:YES];
}

- (IBAction)pausePressed:(id)sender {
    [AGMediaPlayerViewController.sharedInstance pause];
}

- (IBAction)playPressed:(id)sender {
    [AGMediaPlayerViewController.sharedInstance play];
}

- (IBAction)showFullPlayer:(id)sender {
    [AppDelegate.sharedDelegate presentMusicPlayer];
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
