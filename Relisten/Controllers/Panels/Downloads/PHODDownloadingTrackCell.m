//
//  PHODDownloadingTrackCell.m
//  PhishOD
//
//  Created by Alec Gorge on 1/29/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import "PHODDownloadingTrackCell.h"

#import "PhishinDownloader.h"
#import "IGAPIClient.h"
#import "PhishinAPI.h"

#import <LLACircularProgressView/LLACircularProgressView.h>

NSString *PHODDownloadingTrackCellIdentifier = @"phod_download_prog_cell";

@interface PHODDownloadingTrackCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *uiLabelSubtitle;
@property (weak, nonatomic) IBOutlet LLACircularProgressView *uiProgress;

@property (nonatomic) PHODDownloadItem *downloadItem;
@property (nonatomic, readonly) PHODDownloader *downloader;

@end

@implementation PHODDownloadingTrackCell

- (void)awakeFromNib {
    self.uiProgress.tintColor = COLOR_PHISH_GREEN;
    self.uiProgress.hidden = NO;
    self.uiProgress.progress = 0.0f;

    [self.uiProgress addTarget:self
                        action:@selector(stopDownload)
              forControlEvents:UIControlEventTouchUpInside];
}

- (PHODDownloader *)downloader {
    PHODDownloader *manager;
    
#ifdef IS_PHISH
    manager = PhishinAPI.sharedAPI.downloader;
#else
    manager = IGDownloader.sharedInstance;
#endif
    
    return manager;
}

- (void)prepareForReuse {
    if(self.downloadItem) {
        [self.downloader removeDownloadObserver:self
                                forDownloadItem:self.downloadItem];
        
        self.downloadItem = nil;
    }

    self.uiProgress.tintColor = COLOR_PHISH_GREEN;
    self.uiProgress.progress = 0.0f;
    self.uiProgress.hidden = NO;
}

- (void)updateCellWithDownloadItem:(PHODDownloadItem *)item {
    self.downloadItem = item;
    
    if ([item isKindOfClass:PhishinDownloadItem.class]) {
        PhishinDownloadItem *i = (PhishinDownloadItem *)item;
        
        self.uiLabelTitle.text = i.track.title;
        self.uiLabelSubtitle.text = i.show.date;
    }
    else {
        IGDownloadItem *i = (IGDownloadItem *)item;
        
        self.uiLabelTitle.text = i.track.title;
        self.uiLabelSubtitle.text = [NSString stringWithFormat:@"%@ — %@", i.show.artist.name, i.show.displayDate];
    }
    
    [self.downloader addDownloadObserver:self
                         forDownloadItem:self.downloadItem
                                progress:^(int64_t dl, int64_t total) {
                                    self.uiProgress.progress = (dl * 1.0f) / (total * 1.0f);
                                }
                                 success:^(NSURL *destUrl) {
                                     self.uiProgress.progress = 1.0f;
                                     self.uiProgress.hidden = YES;
                                 }
                                 failure:^(NSError *err) {
                                     self.uiProgress.tintColor = UIColor.redColor;
                                 }];
}

- (void)stopDownload {
    if(self.downloadItem) {
        [self.downloader cancelDownloadForDownloadItem:self.downloadItem];
    }
}

@end
