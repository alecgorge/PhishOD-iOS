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

@interface PHODTrackCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiTrackTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackRunningTime;
@property (weak, nonatomic) IBOutlet UILabel *uiTrackNumber;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *uiPlaybackIndicator;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *uiCircularProgress;
@property (weak, nonatomic) IBOutlet UIButton *uiDownloadButton;
@property (weak, nonatomic) IBOutlet UIView *heatmapView;
@property (weak, nonatomic) IBOutlet UIView *heatmapValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heatmapValueHeight;

@property (nonatomic) NSObject<PHODGenericTrack> *track;
@property (nonatomic) NSTimer *progressTimer;

@property (nonatomic) BOOL hasSubtitle;

@end

@implementation PHODTrackCell

- (NSAttributedString *)attributedStringForTrack:(NSObject<PHODGenericTrack> *)track {
    if (!track || !track.title) {
        return nil;
    }
    
    NSMutableAttributedString *att = [NSMutableAttributedString.alloc initWithString:track.title
                                                                          attributes:@{NSFontAttributeName: self.uiTrackTitle.font}];
    if([track respondsToSelector:@selector(show_date)]) {
        NSString *showdate = [track performSelector:@selector(show_date)];
        
        if(showdate) {
            NSAttributedString *str = [NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"\n%@", showdate]
                                                                    attributes:@{
                                                                                 NSFontAttributeName: [UIFont systemFontOfSize:12.0f],
                                                                                 NSForegroundColorAttributeName: UIColor.darkGrayColor
                                                                                 }];
            [att appendAttributedString:str];
        }
    }
    
    return att;
}

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView {
    // dynamic type
    UIFontDescriptor *boldSubhead = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    boldSubhead = [boldSubhead fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    self.uiTrackTitle.font = [UIFont fontWithDescriptor:boldSubhead
                                                   size:0.0f];
    self.uiTrackRunningTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.uiTrackNumber.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    
	self.track = track;
    self.uiTrackNumber.text = @(track.track).stringValue;
    self.uiTrackTitle.attributedText = [self attributedStringForTrack:track];
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
		if(self.track.isCached
		|| AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
			self.uiCircularProgress.hidden =
			self.uiDownloadButton.hidden = YES;
			
			[self stopProgressUpdates];
		}
		else if(self.track.isDownloadingOrQueued) {
			self.uiCircularProgress.hidden = NO;
			self.uiDownloadButton.hidden = YES;
            
            [self.uiCircularProgress setProgress:[self.track.downloader progressForTrack:self.track.downloadItem]
                                        animated:YES];
			
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
	
	[self.track.downloader downloadItem:self.track.downloadItem];
	
	[self updateDownloadButtons];
}

- (IBAction)cancelDownload:(id)sender {
	if (self.track.downloader == nil) {
		return;
	}
	
	PHODDownloadOperation *op = [self.track.downloader findOperationForTrackInQueue:self.track.downloadItem];
	[op cancelDownload];
	
	[self updateDownloadButtons];
}

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 49;
    CGFloat rightMargin = 83;
    
    CGFloat detail = self.hasSubtitle ? self.detailTextLabel.frame.size.width : 0;
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin - detail, MAXFLOAT);
    
    NSAttributedString *att = [self attributedStringForTrack:track];
    CGRect labelSize = [att boundingRectWithSize:constraintSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                         context:nil];
    
    return MAX((tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight), labelSize.size.height + 24);
}

- (void)updateHeatmapLabelWithValue:(float)val {
	// with hue=48, we get the same color as the ratings stars
	CGFloat max_height = self.heatmapView.frame.size.height;
	self.heatmapValueHeight.constant = max_height * val;
    
    [self.heatmapValue setNeedsUpdateConstraints];
//	float min_hue = 48.0/0xFF;
//	float max_hue = 0;
//	float hue = (min_hue - max_hue) * (1.0 - val);
//	self.heatmapValue.backgroundColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
}

- (void)showHeatmap:(BOOL)show {
	self.heatmapView.hidden = !show;
}

- (NSObject<PHODGenericTrack> *)getTrack {
	return _track;
}

@end
