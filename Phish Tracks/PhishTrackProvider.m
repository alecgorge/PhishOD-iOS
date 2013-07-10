//
//  PhishTrackProvider.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTrackProvider.h"
#import <AVFoundation/AVFoundation.h>
#import "NowPlayingViewController.h"
#import <LastFm.h>

@implementation PhishTrackProvider

@synthesize show;
@synthesize position;
@synthesize currentSong;

+(PhishTrackProvider*)sharedInstance {
	static dispatch_once_t once;
    static PhishTrackProvider *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] init];
	});
    return sharedFoo;
}

- (id)init {
	if(self = [super init]) {		
		NSError *activationError = nil;
		AVAudioSession *audioSession = [AVAudioSession sharedInstance];
		[audioSession setCategory:AVAudioSessionCategoryPlayback error:&activationError];
		[audioSession setActive:YES error:&activationError];
		
		self.player = [[AudioPlayer alloc] init];
		self.player.delegate = self;
		
		internalState = 0;
	}
	return self;
}

- (PhishSet *)currentSet {
	return [self setForTrackNumber:self.position];
}

- (PhishSong *)currentSong {
	return [self songForTrackNumber:self.position];
}

- (PhishSong *)songForTrackNumber:(NSUInteger) trackNumber {
	int count = 0;
	for(PhishSet *s in self.show.sets) {
		for(PhishSong *song in s.tracks) {
			if(count == trackNumber) {
				return song;
			}
			count++;
		}
	}
	return nil;
}

- (NSInteger)trackCount; {
	int count = 0;
	for(PhishSet *s in self.show.sets) {
		for(PhishSong *song in s.tracks) {
			count++;
		}
	}
	return count;
}

- (PhishSet *)setForTrackNumber:(NSUInteger) trackNumber {
	int count = 0;
	for(PhishSet *s in self.show.sets) {
		for(PhishSong *song in s.tracks) {
			if(count == trackNumber) {
				return s;
			}
			count++;
		}
	}
	return nil;
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player
		   albumForTrack:(NSUInteger)trackNumber {
    return [self.show.showDate stringByAppendingFormat:@" (%@) - %@ - %@", [self setForTrackNumber:trackNumber].title, self.show.location, self.show.city, nil];
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player
		  artistForTrack:(NSUInteger)trackNumber {
    return @"Phish";
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player
		   titleForTrack:(NSUInteger)trackNumber {
    return [self songForTrackNumber:trackNumber].title;
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player
	   lengthForTrack:(NSUInteger)trackNumber {
    return [self songForTrackNumber:trackNumber].duration;
}

- (void)updateInfo {
	[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{
								MPMediaItemPropertyAlbumTitle: [self musicPlayer:nil albumForTrack:self.position],
									 MPMediaItemPropertyTitle: [self musicPlayer:nil titleForTrack:self.position],
						   MPMediaItemPropertyAlbumTrackCount: [NSNumber numberWithInt:[self trackCount]],
									MPMediaItemPropertyArtist: @"Phish",
						  MPMediaItemPropertyPlaybackDuration: [NSNumber numberWithDouble: [self musicPlayer:nil lengthForTrack:self.position]]
	 }];
}

-(NSInteger)musicPlayer:(BeamMusicPlayerViewController*)player
		 didChangeTrack:(NSUInteger)track {
	PhishSong *song = [self songForTrackNumber:track];
	[Flurry logEvent:@"playedTrack"
	  withParameters:@{
		@"song_name": song.title,
		@"concert": self.show.showDate,
		@"file": song.filePath
	}];
	dbug(@"musicPlayer:didChangeTrack");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
	
	[self updateInfo];
	
	if(track == queuedTrack) {
		BOOL myBoolValue = YES; // or NO
		
		NSMethodSignature* signature = [[self.player class] instanceMethodSignatureForSelector:@selector(processQueue:)];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
		[invocation setTarget:self.player];
		[invocation setSelector:@selector(processQueue:)];
		[invocation setArgument:&myBoolValue
						atIndex:2];
		[invocation invoke];
	}
	else {
		[self.player setDataSource:[self.player dataSourceFromURL:song.fileURL]
				   withQueueItemId:[self songForTrackNumber:track].filePath];
	}
	
	if([self songForTrackNumber:track+1]) {
		queuedTrack = track + 1;
		[self.player queueDataSource:[self.player dataSourceFromURL:[self songForTrackNumber:track+1].fileURL]
					 withQueueItemId:[self songForTrackNumber:track+1].filePath];
	}
	
	self.position = track;
	
	return track;
}

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
	dbug(@"musicPlayerDidStartPlaying");
	[self.player resume];
	[self updateInfo];
}

-(void)musicPlayerDidStopPlaying:(BeamMusicPlayerViewController *)player {
	dbug(@"musicPlayerDidStopPlaying");
	[self.player pause];
	[self updateInfo];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player
 didSeekToPosition:(CGFloat)_position {
    [self.player seekToTime:_position];
}

- (NSInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player {
	int count = 0;
	for(PhishSet *s in self.show.sets) {
		count += s.tracks.count;
	}
	
	return count;
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player
   didChangeVolume:(CGFloat)volume {
    MPMusicPlayerController.iPodMusicPlayer.volume = volume;
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer
	   stateChanged:(AudioPlayerState)state {
	dbug(@"state changed: %d", state);
	if(state == AudioPlayerStatePlaying) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
		[[NowPlayingViewController sharedInstance] play];
	}
	else if(state == AudioPlayerStatePaused) {
		[[NowPlayingViewController sharedInstance] pause];
	}
	else if(state == AudioPlayerStateStopped
			|| state == AudioPlayerStateError) {
		[[NowPlayingViewController sharedInstance] stop];
	}
	[self updateInfo];
}


-(void) audioPlayer:(AudioPlayer*)audioPlayer
internalStateChanged:(AudioPlayerInternalState)state {
	internalState = state;
	dbug(@"audioPlayer:internalStateChanged: %d", state);
	if(state == AudioPlayerInternalStateError) {
		dbug(@"%d", audioPlayer.stopReason);
	}
	
	[NowPlayingViewController sharedInstance].currentPlaybackPosition = audioPlayer.progress;
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer
  didEncounterError:(AudioPlayerErrorCode)errorCode {
	dbug(@"error: %d", errorCode);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
												message:[NSString stringWithFormat:@"%d", errorCode]
											   delegate:nil
									  cancelButtonTitle:@"OK"
									  otherButtonTitles: nil];
	[a show];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer
didStartPlayingQueueItemId:(NSObject*)queueItemId {
	[[LastFm sharedInstance] sendNowPlayingTrack:[self currentSong].title
										byArtist:@"Phish"
										 onAlbum:[self musicPlayer:nil albumForTrack:self.position]
									withDuration:[self musicPlayer:nil lengthForTrack:self.position]
								  successHandler:nil
								  failureHandler:nil];
	dbug(@"did start playing: %@", queueItemId);
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer
didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	dbug(@"did finish buffering: %@", queueItemId);
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer
didFinishPlayingQueueItemId:(NSObject*)queueItemId
		 withReason:(AudioPlayerStopReason)stopReason
		andProgress:(double)progress
		andDuration:(double)duration {
	if(duration > .5 * [self currentSong].duration) {
		[[LastFm sharedInstance] sendScrobbledTrack:[self currentSong].title
										   byArtist:@"Phish"
											onAlbum:[self musicPlayer:nil albumForTrack:self.position]
									   withDuration:[self musicPlayer:nil lengthForTrack:self.position]
										atTimestamp:(int)[[NSDate date] timeIntervalSince1970]
									 successHandler:nil
									 failureHandler:nil];
	}
	dbug(@"did finish playing: %@", queueItemId);
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	[self updateInfo];
}


@end
