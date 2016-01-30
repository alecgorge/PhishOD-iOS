//
//  PhishinDownloader.h
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PHODDownloadState) {
	PHODDownloadStateReady = 0,
	PHODDownloadStateDownloading,
    PHODDownloadStateDone,
	PHODDownloadStateCancelled,
	PHODDownloadStateFailed,
};

@import TCBlobDownloadSwift;

@interface PHODDownloadItem : NSObject

+ (id)showForPath:(NSString *)path;
+ (void)showsWithCachedTracks:(void(^)(NSArray *))success;
+ (NSString *)provider;
+ (NSString *)cacheDir;

+ (long long)completeCachedSize;
+ (void)deleteEntireCache;

- (instancetype)initWithId:(NSInteger)eyed
              andCachePath:(NSString *)cachePath;

@property (nonatomic, readonly) NSInteger id;
@property (nonatomic, readonly) NSString *cachePath;
@property (nonatomic, readonly) NSString *provider;
@property (nonatomic, readonly) NSURL *cachedFile;
@property (nonatomic, readonly) BOOL isCached;

@property (nonatomic) TCBlobDownload *blob;

- (NSURL *)downloadURL;
- (void)cache;
- (void)delete;

@end

@interface PhishinDownloadItem : PHODDownloadItem

@property (nonatomic, readonly) PhishinTrack *track;
@property (nonatomic, readonly) PhishinShow *show;

- (instancetype)initWithTrack:(PhishinTrack *)track
                      andShow:(PhishinShow *)show;

@end

@class PHODDownloader;

@protocol PHODDownloaderDelegate <NSObject>

- (void)downloader:(PHODDownloader *)downloader
      itemSucceded:(PHODDownloadItem *)item;

- (void)downloader:(PHODDownloader *)downloader
       itemStarted:(PHODDownloadItem *)item;

- (void)downloader:(PHODDownloader *)downloader
     itemCancelled:(PHODDownloadItem *)item;

- (void)downloader:(PHODDownloader *)downloader
        itemFailed:(PHODDownloadItem *)item;

@end

@interface PHODDownloader : NSObject

@property (nonatomic, readonly) NSMutableArray<PHODDownloadItem *> *downloading;
@property (nonatomic, readonly) NSMutableArray<PHODDownloadItem *> *downloadQueue;

@property (nonatomic) NSUInteger maxConcurrentDownloads; // default = 2
@property (nonatomic, weak) id<PHODDownloaderDelegate> delegate;

- (TCBlobDownload *)downloadItem:(PHODDownloadItem *)item;

- (void)addDownloadObserver:(NSObject *)observer
                      forId:(NSInteger)eyed
                   progress:(void (^)(int64_t, int64_t))progress
                    success:(void (^)(NSURL *))success
                    failure:(void (^)(NSError *))failure;

- (void)addDownloadObserver:(NSObject *)observer
            forDownloadItem:(PHODDownloadItem *)item
                   progress:(void (^)(int64_t, int64_t))progress
                    success:(void (^)(NSURL *))success
                    failure:(void (^)(NSError *))failure;

- (void)removeDownloadObserver:(NSObject *)observer
                         forId:(NSInteger)eyed;

- (void)removeDownloadObserver:(NSObject *)observer
               forDownloadItem:(PHODDownloadItem *)item;

- (BOOL)isTrackDownloadingOrQueued:(NSInteger)track;
- (PHODDownloadItem *)findItemForItemIdInQueue:(NSInteger)track;

- (CGFloat)progressForTrack:(NSInteger)track;

- (void)cancelDownloadForDownloadItem:(PHODDownloadItem *)item;
- (void)cancelDownloadForTrackId:(NSInteger)eyed;

@end

@interface PhishinDownloader : PHODDownloader

+(instancetype)sharedInstance;

-(PhishinDownloadItem *)downloadTrack:(PhishinTrack *)track
                               inShow:(PhishinShow *)show;

@end

