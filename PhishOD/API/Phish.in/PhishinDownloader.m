//
//  PhishinDownloader.m
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinDownloader.h"

#import <FCFileManager/FCFileManager.h>
#import <KVOController/FBKVOController.h>
#import <EGOCache/EGOCache.h>

static NSString *kPhishinDownloaderShowsKey = @"phishod.shows";

@interface PhishinDownloader ()

@property (nonatomic, readonly) NSString *cacheDir;

@end

@implementation PhishinDownloader

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static PhishinDownloader *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [self.alloc init];
	});
    return sharedFoo;
}

- (id)init {
	if (self = [super init]) {
		self.queue = NSOperationQueue.alloc.init;
		self.queue.maxConcurrentOperationCount = 3;		
	}
	return self;
}

- (PhishinDownloadOperation *)downloadTrack:(PhishinTrack *)track
									 inShow:(PhishinShow *)show
								   progress:(void (^)(int64_t, int64_t))progress
									success:(void (^)(NSURL *))success
									failure:(void (^)(NSError *))failure {
	PhishinDownloadOperation *op = [PhishinDownloadOperation.alloc initWithTrack:track
																		  inShow:show
																		progress:progress
																		 success:success
																		 failure:failure];
	
	[self.queue addOperation:op];
	
	return op;
}

- (PhishinDownloadOperation *)downloadTrack:(PhishinTrack *)track
									 inShow:(PhishinShow *)show {
	PhishinDownloadOperation *op = [PhishinDownloadOperation.alloc initWithTrack:track
																		  inShow:show
																		progress:nil
																		 success:nil
																		 failure:nil];
	
	[self.queue addOperation:op];
	
	return op;
}

- (NSURL *)isTrackCached:(PhishinTrack *)track
				  inShow:(PhishinShow *)show {
	return [PhishinDownloadOperation isTrackCached:track
											inShow:show];
}

- (PhishinDownloadOperation *)findOperationForTrackInQueue:(PhishinTrack *)track {
	return [self.queue.operations detect:^BOOL(PhishinDownloadOperation *op) {
		return op.track.id == track.id;
	}];
}

- (BOOL)isTrackDownloadedOrQueued:(PhishinTrack *)track {
	return [self findOperationForTrackInQueue:track] != nil;
}

- (CGFloat)progressForTrack:(PhishinTrack *)track {
	PhishinDownloadOperation *o = [self findOperationForTrackInQueue:track];
	
	if(!o) {
		return 0.0f;
	}
	
	return o.downloadProgress;
}

- (void)showsWithCachedTracks:(void (^)(NSArray *))success {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
		NSArray *arr = [FCFileManager listItemsInDirectoryAtPath:[PhishinDownloadOperation.cacheDir stringByAppendingPathComponent:@"phish.in"]
															deep:NO];
		
		arr = [arr map:^id(NSString *path) {
			PhishinShow *s = [PhishinShow loadShowFromCacheForShowDate:path.lastPathComponent];
			return s;
		}];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			success(arr);
		});
	});
}

@end

@interface PhishinDownloadOperation ()

@property (nonatomic) NSURLSessionDownloadTask *dl;

@end

@implementation PhishinDownloadOperation

- (instancetype)initWithTrack:(PhishinTrack *)track
					   inShow:(PhishinShow *)show
					 progress:(void (^)(int64_t, int64_t))progress
					  success:(void (^)(NSURL *))success
					  failure:(void (^)(NSError *))failure{
	if (self = [super init]) {
		self.track = track;
		self.show = show;
		
		self.progress = progress;
		self.success = success;
		self.failure = failure;
	}
	return self;
}

+ (NSString *)cacheDir {
	return [FCFileManager pathForCachesDirectoryWithPath:@"com.alecgorge.phish.cache/com.alecgorge.phish.cache"];
}

+ (NSString *)cachePathForTrack:(PhishinTrack *)track
						 inShow:(PhishinShow *)show {
	return [self.cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"phish.in/%@/%@.mp3", show.date, @(track.id).stringValue]];
}

+ (NSString *)incompleteCachePathForTrack:(PhishinTrack *)track
								   inShow:(PhishinShow *)show {
	return [self.cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"incomplete/phish.in/%@/%@.mp3", show.date, @(track.id).stringValue]];
}

+ (NSURL *)isTrackCached:(PhishinTrack *)track
				  inShow:(PhishinShow *)show {
	NSAssert(show != nil, @"show cannot be nil");
	NSAssert(track != nil, @"track cannot be nil");

	NSString *path = [self cachePathForTrack:track
									  inShow:show];
	
	return [FCFileManager existsItemAtPath:path] ? [NSURL fileURLWithPath:path] : nil;
}

- (CGFloat)downloadProgress {
	return self.totalBytes == 0 ? 0 : (1.0f * self.completedBytes / self.totalBytes);
}

- (void)downloadTrack:(PhishinTrack *)track
			   inShow:(PhishinShow *)show
			 progress:(void (^)(int64_t, int64_t))progress
			  success:(void (^)(NSURL *fileURL)) success
			  failure:(void ( ^ ) ( NSError *error ))failure {
	static NSURLSessionConfiguration *downloadConfig = nil;
	static AFURLSessionManager *manager = nil;
	static FBKVOController *kvo = nil;
	
	if(kvo == nil) {
		kvo = [FBKVOController controllerWithObserver:self];
	}
	
	if(!downloadConfig || !manager) {
		downloadConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"phishin"];
		
		manager = [AFURLSessionManager.alloc initWithSessionConfiguration:downloadConfig];
	}
	
	NSString *incompleteCachePath = [PhishinDownloadOperation incompleteCachePathForTrack:track
																				   inShow:show];
	NSString *completeCachePath = [PhishinDownloadOperation cachePathForTrack:track
																	   inShow:show];
	
	if ([FCFileManager existsItemAtPath:completeCachePath]) {
		if(success) {
			success([NSURL fileURLWithPath:completeCachePath]);
		}
		
		return;
	}
	
	// ensure directory structure exists
	[FCFileManager createDirectoriesForFileAtPath:incompleteCachePath
											error:nil];
	[FCFileManager createDirectoriesForFileAtPath:completeCachePath
											error:nil];
	
	NSURL *downloadURL = track.mp3;
	
	// setup blocks for new & resume download
	NSProgress *rootProgress = nil;
	NSURL* (^destination)(NSURL *, NSURLResponse *) = ^(NSURL *targetPath, NSURLResponse *response) {
		return [NSURL fileURLWithPath:incompleteCachePath];
	};
	
	void (^completion)(NSURLResponse *, NSURL *, NSError *) = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if(error) {
			dbug(@"download error: %@", error);
			
			self.state = PhishinDownloadStateFailed;
			
			if (failure) {
				failure(error);
			}
			
			return;
		}
		else {
			dbug(@"download completed: %@. moving to %@", filePath.path, completeCachePath);
			
			self.state = PhishinDownloadStateDone;
			
			[FCFileManager moveItemAtPath:filePath.path
								   toPath:completeCachePath];
		
			EGOCache *cache = EGOCache.globalCache;
			[cache setObject:show
					  forKey:show.cacheKey];
			
			if(success) {
				success([NSURL URLWithString:completeCachePath]);
			}
		}
	};
	// end blocks
	
	if([FCFileManager existsItemAtPath:incompleteCachePath]) {
		self.dl = [manager downloadTaskWithResumeData:[FCFileManager readFileAtPathAsData:incompleteCachePath]
											 progress:&rootProgress
										  destination:destination
									completionHandler:completion];
	}
	else {
		self.dl = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:downloadURL]
										  progress:&rootProgress
									   destination:destination
								 completionHandler:completion];
	}
	
	[kvo observe:rootProgress
		 keyPath:@"fractionCompleted"
		 options:NSKeyValueObservingOptionNew
		   block:^(id observer, NSProgress *p, NSDictionary *change) {
			   self.totalBytes = p.totalUnitCount;
			   self.completedBytes = p.completedUnitCount;
			   
			   if(progress) {
				   progress(p.totalUnitCount, p.completedUnitCount);
			   }
		   }];
	
	[self.dl resume];
}

- (void)start {
	self.state = PhishinDownloadStateDownloading;
	
	[self downloadTrack:self.track
				 inShow:self.show
			   progress:self.progress
				success:self.success
				failure:self.failure];
}

- (void)cancelDownload {
	self.state = PhishinDownloadStateCancelled;

	[self cancel];
	
	[self.dl cancel];
}

- (BOOL)isExecuting {
	return self.state == PhishinDownloadStateDownloading;
}

- (BOOL)isFinished {
	return self.state == PhishinDownloadStateDone ||
		   self.state == PhishinDownloadStateCancelled ||
		   self.state == PhishinDownloadStateFailed;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)setState:(PhishinDownloadState)state {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	
    _state = state;
	
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];

}

@end
