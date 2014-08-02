//
//  PHODTrackCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODTrackCell.h"

#import <NAKPlaybackIndicatorView/NAKPlaybackIndicatorView.h>
#import <LLACircularProgressView/LLACircularProgressView.h>

#import "IGDurationHelper.h"
#import "AGMediaPlayerViewController.h"

#import "PhishinTrack.h"

@interface PHODTrackCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiTrackTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackRunningTime;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackNumber;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *uiPlaybackIndicator;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *uiCircularProgress;
@property (weak, nonatomic) IBOutlet UIButton *uiDownloadButton;

@property (nonatomic) NSObject<PHODGenericTrack> *track;
@property (nonatomic) NSTimer *progressTimer;

@end

@implementation PHODTrackCell

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView {
	self.track = track;
    self.uiTrackNumber.text = @(track.track).stringValue;
    self.uiTrackTitle.text = track.title;
    self.uiTrackRunningTime.text = [IGDurationHelper formattedTimeWithInterval:track.duration];
	
	[self updateDownloadButtons];
	
    self.uiPlaybackIndicator.tintColor = COLOR_PHISH_GREEN;
    if(track.id == AGMediaPlayerViewController.sharedInstance.currentItem.id) {
        self.uiTrackNumber.hidden = YES;
        if(AGMediaPlayerViewController.sharedInstance.playing) {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePlaying;
        }
        else {
            self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStatePaused;
        }
    }
    else {
        self.uiTrackNumber.hidden = NO;
        self.uiPlaybackIndicator.state = NAKPlaybackIndicatorViewStateStopped;
    }
	
	if(AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
		if(!track.isCached) {
			self.uiTrackTitle.alpha =
			self.uiTrackRunningTime.alpha =
			self.uiTrackNumber.alpha = 0.5;
			self.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		else {
			self.uiTrackTitle.alpha =
			self.uiTrackRunningTime.alpha =
			self.uiTrackNumber.alpha = 1.0;
			self.selectionStyle = UITableViewCellSelectionStyleDefault;
		}
	}
}

- (void)pollForProgressUpdates {
	if(self.progressTimer != nil) {
		return;
	}
	
	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
														  target:self
														selector:@selector(updateDownloadButtons)
														userInfo:nil
														 repeats:YES];
}

- (void)updateDownloadButtons {
	if(!self.track.isCacheable) {
		self.uiCircularProgress.hidden =
		self.uiDownloadButton.hidden = YES;
	}
	else {
		// phishin track
		PhishinTrack *pt = (PhishinTrack *)self.track;
		
		if(pt.isCached
		|| AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
			self.uiCircularProgress.hidden =
			self.uiDownloadButton.hidden = YES;
			
			[self stopProgressUpdates];
		}
		else if([pt respondsToSelector:@selector(isDownloadingOrQueued)] && pt.isDownloadingOrQueued) {
			self.uiCircularProgress.hidden = NO;
			self.uiDownloadButton.hidden = YES;
			self.uiCircularProgress.progress = [pt.downloader progressForTrack:pt];
			
			[self pollForProgressUpdates];
		}
		else {
			self.uiCircularProgress.hidden = YES;
			self.uiDownloadButton.hidden = NO;
			
			[self stopProgressUpdates];
		}
	}
}

- (void)stopProgressUpdates {
	if(!self.progressTimer) {
		return;
	}
	
	[self.progressTimer invalidate];
	self.progressTimer = nil;
}

- (void)dealloc {
	[self stopProgressUpdates];
}

- (IBAction)download:(id)sender {
	if (self.track.downloader == nil) {
		return;
	}
	
	PhishinTrack *pt = (PhishinTrack *)self.track;
	[pt.downloader downloadTrack:pt
						  inShow:pt.show];
	
	[self updateDownloadButtons];
}

- (IBAction)cancelDownload:(id)sender {
	if (self.track.downloader == nil) {
		return;
	}
	
	PhishinTrack *pt = (PhishinTrack *)self.track;
	PhishinDownloadOperation *op = [pt.downloader findOperationForTrackInQueue:pt];
	
	[op cancelDownload];
	
	[self updateDownloadButtons];
}

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 49;
    CGFloat rightMargin = 66;
    
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin, MAXFLOAT);
    CGRect labelSize = [track.title boundingRectWithSize:constraintSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]}
                                                 context:nil];
    
    return MAX(tableView.rowHeight, labelSize.size.height + 24);
}

@end
