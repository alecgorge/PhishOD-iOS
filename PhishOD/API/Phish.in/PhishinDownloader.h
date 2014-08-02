//
//  PhishinDownloader.h
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhishinDownloadOperation;

typedef NS_ENUM(NSInteger, PhishinDownloadState) {
	PhishinDownloadStateReady = 0,
	PhishinDownloadStateDownloading,
	PhishinDownloadStateDone,
	PhishinDownloadStateCancelled,
	PhishinDownloadStateFailed,
};

@interface PhishinDownloader : NSObject

@property (nonatomic) NSOperationQueue *queue;

+(instancetype)sharedInstance;

-(PhishinDownloadOperation *)downloadTrack:(PhishinTrack *)track
									inShow:(PhishinShow *)show
								  progress:(void (^)(int64_t totalBytes, int64_t completedBytes))progress
								   success:(void (^)(NSURL *fileURL)) success
								   failure:(void ( ^ ) ( NSError *error ))failure;

-(PhishinDownloadOperation *)downloadTrack:(PhishinTrack *)track
									inShow:(PhishinShow *)show;

- (NSURL *)isTrackCached:(PhishinTrack *)track
				  inShow:(PhishinShow *)show;

- (PhishinDownloadOperation *)findOperationForTrackInQueue:(PhishinTrack *)track;
- (BOOL)isTrackDownloadedOrQueued:(PhishinTrack *)track;
- (CGFloat)progressForTrack:(PhishinTrack *)track;

- (void)showsWithCachedTracks:(void(^)(NSArray *))success;

@end

@interface PhishinDownloadOperation : NSOperation

@property (nonatomic) PhishinTrack *track;
@property (nonatomic) PhishinShow *show;

@property (nonatomic) int64_t totalBytes;
@property (nonatomic) int64_t completedBytes;
@property (nonatomic, readonly) CGFloat downloadProgress;

@property (nonatomic, copy) void (^progress)(int64_t totalBytes, int64_t completedBytes);
@property (nonatomic, copy) void (^success)(NSURL *fileURL);
@property (nonatomic, copy) void (^failure)(NSError *error);

@property (nonatomic) PhishinDownloadState state;

+ (NSString *)cacheDir;

+ (NSURL *)isTrackCached:(PhishinTrack *)track
				  inShow:(PhishinShow *)show;

- (instancetype)initWithTrack:(PhishinTrack *)track
					   inShow:(PhishinShow *)show
					 progress:(void (^)(int64_t totalBytes, int64_t completedBytes))progress
					  success:(void (^)(NSURL *fileURL)) success
					  failure:(void ( ^ ) ( NSError *error ))failure;

- (void)cancelDownload;

@end
