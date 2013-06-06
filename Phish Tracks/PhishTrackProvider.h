//
//  PhishTrackProvider.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BeamMusicPlayerViewController/BeamMusicPlayerDataSource.h>
#import <BeamMusicPlayerViewController/BeamMusicPlayerDelegate.h>
#import <BeamMusicPlayerViewController/BeamMusicPlayerViewController.h>
#import <AudioPlayer.h>

@interface PhishTrackProvider : NSObject<BeamMusicPlayerDelegate, BeamMusicPlayerDataSource, AudioPlayerDelegate> {
	AudioPlayerInternalState internalState;
	NSUInteger queuedTrack;
}

@property PhishShow *show;
@property NSInteger position;
@property (readonly) PhishSong *currentSong;
@property AudioPlayer *player;
+(PhishTrackProvider*)sharedInstance;

@end
