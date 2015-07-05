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

- (void)downloadURL:(void(^)(NSURL *))dl;
- (void)cache;
- (void)delete;

@end

@interface PhishinDownloadItem : PHODDownloadItem

@property (nonatomic, readonly) PhishinTrack *track;
@property (nonatomic, readonly) PhishinShow *show;

- (instancetype)initWithTrack:(PhishinTrack *)track
                      andShow:(PhishinShow *)show;

@end

@interface PHODDownloadOperation : NSOperation

@property (nonatomic) PHODDownloadState state;
@property (nonatomic) PHODDownloadItem *item;

@property (nonatomic) int64_t totalBytes;
@property (nonatomic) int64_t completedBytes;
@property (nonatomic, readonly) CGFloat downloadProgress;

@property (nonatomic, copy) void (^progress)(int64_t totalBytes, int64_t completedBytes);
@property (nonatomic, copy) void (^success)(NSURL *fileURL);
@property (nonatomic, copy) void (^failure)(NSError *error);

- (instancetype)initWithDownloadItem:(PHODDownloadItem *)item
                            progress:(void (^)(int64_t totalBytes, int64_t completedBytes))progress
                             success:(void (^)(NSURL *fileURL)) success
                             failure:(void ( ^ ) ( NSError *error ))failure;

- (void)cancelDownload;

@end

@interface PHODDownloader : NSObject

@property (nonatomic) NSOperationQueue *queue;

- (PHODDownloadOperation *)downloadItem:(PHODDownloadItem *)item
                               progress:(void (^)(int64_t, int64_t))progress
                                success:(void (^)(NSURL *))success
                                failure:(void (^)(NSError *))failure;

- (PHODDownloadOperation *)downloadItem:(PHODDownloadItem *)item;

- (PHODDownloadOperation *)findOperationForTrackInQueue:(PHODDownloadItem *)track;
- (BOOL)isTrackDownloadedOrQueued:(PHODDownloadItem *)track;
- (CGFloat)progressForTrack:(PHODDownloadItem *)track;

@end

@interface PhishinDownloader : PHODDownloader

+(instancetype)sharedInstance;

-(PHODDownloadOperation *)downloadTrack:(PhishinTrack *)track
                                 inShow:(PhishinShow *)show
                               progress:(void (^)(int64_t totalBytes, int64_t completedBytes))progress
                                success:(void (^)(NSURL *fileURL)) success
                                failure:(void ( ^ ) ( NSError *error ))failure;

@end

