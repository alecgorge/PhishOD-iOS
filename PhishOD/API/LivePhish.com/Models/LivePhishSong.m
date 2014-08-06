//
//  LivePhishSong.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishSong.h"

#import "LivePhishCompleteContainer.h"

@implementation LivePhishSong

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"trackID": @"id",
                           @"songTitle": @"title",
                           @"discNum": @"disc",
                           @"trackNum": @"track",
                           @"setNum": @"set",
                           @"clipURL": @"clipURL",
                           @"songID": @"songId",
                           @"totalRunningTime": @"runningTime",
                           };
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

- (NSTimeInterval)duration {
    return self.runningTime;
}

- (PHODDownloader *)downloader {
	return LivePhishDownloader.sharedInstance;
}

- (NSInteger)trackId {
	return self.id;
}

- (BOOL)isCacheable {
    if(self.container && !self.container.canStream) {
        return NO;
    }
    
	return YES;
}

- (BOOL)isCached {
	return self.downloadItem.isCached;
}

- (BOOL)isDownloadingOrQueued {
    LivePhishDownloadItem *item = [LivePhishDownloadItem.alloc initWithSong:self
                                                               andContainer:self.container];
    
	return [self.downloader isTrackDownloadedOrQueued:item];
}

- (NSURL *)cachedFile {
    LivePhishDownloadItem *item = [LivePhishDownloadItem.alloc initWithSong:self
                                                               andContainer:self.container];
        
    return item.cachedFile;
}

- (PHODDownloadItem *)downloadItem {
    return [LivePhishDownloadItem.alloc initWithSong:self
                                        andContainer:self.container];
}

@end
