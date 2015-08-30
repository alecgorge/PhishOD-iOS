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
#import "PHODPersistence.h"

static NSString *kPhishinDownloaderShowsKey = @"phishod.shows";

@implementation PHODDownloadItem

+ (id)showForPath:(NSString *)path {
    return nil;
}

+ (NSString *)provider {
    return nil;
}

+ (NSString *)cacheDir {
	return [FCFileManager pathForDocumentsDirectoryWithPath:@"com.alecgorge.phish.cache/"];
}

+ (long long)completeCachedSize {
    long long size = 0;
    for (NSString *path in [FCFileManager listItemsInDirectoryAtPath:[self cacheDir]
                                                                deep:YES]) {
        size += [FCFileManager sizeOfItemAtPath:path].longLongValue;
    }
    
    return size;
}

+ (void)deleteEntireCache {
    for (NSString *path in [FCFileManager listItemsInDirectoryAtPath:[self cacheDir]
                                                                deep:YES]) {
        [FCFileManager removeItemAtPath:path];
    }
}

+ (void)showsWithCachedTracks:(void (^)(NSArray *))success {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        NSString *path = [[self cacheDir] stringByAppendingPathComponent:[self provider]];
        
        dbug(@"searching %@", path);
        
		NSArray *arr = [FCFileManager listItemsInDirectoryAtPath:path
															deep:NO];
		
		arr = [arr map:^id(NSString *path) {
			return [self showForPath:path];
		}];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			success(arr);
		});
	});
}

- (instancetype)initWithId:(NSInteger)eyed
              andCachePath:(NSString *)cachePath {
    if (self = [super init]) {
        _id = eyed;
        _cachePath = cachePath;
    }
    return self;
}

- (NSString *)provider {
    return [PHODDownloadItem provider];
}

- (NSString *)completeCachePath {
	return [[PHODDownloadItem cacheDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", self.provider, self.cachePath]];
}

- (NSString *)incompleteCachePath {
	return [[PHODDownloadItem cacheDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"incomplete/%@/%@", self.provider, self.cachePath]];
}

- (NSURL *)cachedFile {
    NSString *path = self.completeCachePath;

    return [FCFileManager existsItemAtPath:path] ? [NSURL fileURLWithPath:path] : nil;
}

- (BOOL)isCached {
	return (self.cachedFile != nil);
}

- (void)cache {
    
}

- (void)delete {
    [FCFileManager removeItemAtPath:[self completeCachePath]];
    
    // remove 1234.mp3 from Library/Caches/....cache/...cache/phish.in/2012-08-19/1234.mp3
    NSString *showDir = [self.completeCachePath stringByDeletingLastPathComponent];
    NSArray *contents = [FCFileManager listFilesInDirectoryAtPath:showDir];
    
    if(contents.count == 0) {
        [FCFileManager removeItemAtPath:showDir];
    }
}

- (void)downloadURL:(void (^)(NSURL *))dl {
    NSAssert(NO, @"this needs to be overriden");
}

@end

@implementation PhishinDownloadItem

+ (NSString *)provider {
    return @"phish.in";
}

+ (id)showForPath:(NSString *)path {
    return [PhishinShow loadShowFromCacheForShowDate:path.lastPathComponent];
}

- (instancetype)initWithTrack:(PhishinTrack *)track
                      andShow:(PhishinShow *)show {
    if (self = [super init]) {
        _track = track;
        _show = show;
    }
    return self;
}

- (NSString *)cachePath {
    return [NSString stringWithFormat:@"%@/%@.mp3", self.show.date, @(self.track.id).stringValue];
}

- (NSString *)provider {
    return [PhishinDownloadItem provider];
}

- (NSInteger)id {
    return self.track.id;
}

- (void)downloadURL:(void (^)(NSURL *))dl {
    dl(self.track.mp3);
}

- (void)cache {
    [self.show cache];
}

@end

@interface PHODDownloader ()

@property (nonatomic, readonly) NSString *cacheDir;

@end

@implementation PHODDownloader

- (id)init {
	if (self = [super init]) {
		self.queue = NSOperationQueue.alloc.init;
		self.queue.maxConcurrentOperationCount = 2;
	}
	return self;
}

- (PHODDownloadOperation *)downloadItem:(PHODDownloadItem *)item
                               progress:(void (^)(int64_t, int64_t))progress
                                success:(void (^)(NSURL *))success
                                failure:(void (^)(NSError *))failure {
	PHODDownloadOperation *op = [PHODDownloadOperation.alloc initWithDownloadItem:item
                                                                         progress:progress
                                                                          success:success
                                                                          failure:failure];
	
	[self.queue addOperation:op];
	
	return op;
}

- (PHODDownloadOperation *)downloadItem:(PHODDownloadItem *)item {
    return [self downloadItem:item
                     progress:nil
                      success:nil
                      failure:nil];
}

- (PHODDownloadOperation *)findOperationForTrackInQueue:(PHODDownloadItem *)track {
	return [self.queue.operations detect:^BOOL(PHODDownloadOperation *op) {
		return op.item.id == track.id;
	}];
}

- (BOOL)isTrackDownloadedOrQueued:(PHODDownloadItem *)track {
	return [self findOperationForTrackInQueue:track] != nil;
}

- (CGFloat)progressForTrack:(PHODDownloadItem *)track {
	PHODDownloadOperation *o = [self findOperationForTrackInQueue:track];
	
	if(!o) {
		return 0.0f;
	}
	
	return o.downloadProgress;
}

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

- (PHODDownloadOperation *)downloadTrack:(PhishinTrack *)track
                                  inShow:(PhishinShow *)show
                                progress:(void (^)(int64_t, int64_t))progress
                                 success:(void (^)(NSURL *))success
                                 failure:(void (^)(NSError *))failure {
    return [self downloadItem:[PhishinDownloadItem.alloc initWithTrack:track
                                                               andShow:show]
                     progress:progress
                      success:success
                      failure:failure];
}

@end

@interface PHODDownloadOperation ()

@property (nonatomic) NSURLSessionDownloadTask *dl;
@property (nonatomic) NSProgress *rootProgress;

@end

@implementation PHODDownloadOperation

- (instancetype)initWithDownloadItem:(PHODDownloadItem *)item
                            progress:(void (^)(int64_t, int64_t))progress
                             success:(void (^)(NSURL *))success
                             failure:(void (^)(NSError *))failure{
	if (self = [super init]) {
		self.item = item;
		
		self.progress = progress;
		self.success = success;
		self.failure = failure;
	}
	return self;
}

- (CGFloat)downloadProgress {
	return self.totalBytes == 0 ? 0 : (1.0f * self.completedBytes / self.totalBytes);
}

- (void)download {
	static NSURLSessionConfiguration *downloadConfig = nil;
	static AFURLSessionManager *manager = nil;
	static FBKVOController *kvo = nil;
	
	if(kvo == nil) {
		kvo = [FBKVOController controllerWithObserver:self];
	}
	
	if(!downloadConfig || !manager) {
		downloadConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"phishod"];
        downloadConfig.HTTPAdditionalHeaders = @{
                                                 @"User-Agent": @"LivePhishApp/1.2 CFNetwork/672.1.15 Darwin/14.0.0"
                                                 };
        
		manager = [AFURLSessionManager.alloc initWithSessionConfiguration:downloadConfig];
	}
	
	NSString *incompleteCachePath = [self.item incompleteCachePath];
	NSString *completeCachePath = [self.item completeCachePath];
	
	if ([FCFileManager existsItemAtPath:completeCachePath]) {
		if(self.success) {
			self.success([NSURL fileURLWithPath:completeCachePath]);
		}
		
		return;
	}
	
	// ensure directory structure exists
	[FCFileManager createDirectoriesForFileAtPath:incompleteCachePath
											error:nil];
	[FCFileManager createDirectoriesForFileAtPath:completeCachePath
											error:nil];
    
    dbug(@"incompleteCachePath: %@", incompleteCachePath);
    dbug(@"completeCachePath: %@", completeCachePath);
	
	// setup blocks for new & resume download
    __block NSProgress * rootProgress;
	NSURL* (^destination)(NSURL *, NSURLResponse *) = ^(NSURL *targetPath, NSURLResponse *response) {
		return [NSURL fileURLWithPath:incompleteCachePath];
	};
	
	void (^completion)(NSURLResponse *, NSURL *, NSError *) = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if(error) {
			dbug(@"download error: %@", error);
			
			self.state = PHODDownloadStateFailed;
			
			if (self.failure) {
				self.failure(error);
			}
			
			return;
		}
		else {
			dbug(@"download completed: %@. moving to %@", filePath.path, completeCachePath);
			
			self.state = PHODDownloadStateDone;
			
			[FCFileManager moveItemAtPath:filePath.path
								   toPath:completeCachePath];
		
            [self.item cache];
			
			if(self.success) {
				self.success([NSURL URLWithString:completeCachePath]);
			}
		}
	};
    
    void (^observeBlock)(id, NSProgress *, NSDictionary *) = ^(id observer, NSProgress *p, NSDictionary *change) {
        self.totalBytes = p.totalUnitCount;
        self.completedBytes = p.completedUnitCount;
        
        if(self.progress) {
            self.progress(p.totalUnitCount, p.completedUnitCount);
        }
    };
	// end blocks
	
	if([FCFileManager existsItemAtPath:incompleteCachePath]) {
		self.dl = [manager downloadTaskWithResumeData:[FCFileManager readFileAtPathAsData:incompleteCachePath]
											 progress:&rootProgress
										  destination:destination
									completionHandler:completion];
        
        [kvo observe:rootProgress
             keyPath:@"fractionCompleted"
             options:NSKeyValueObservingOptionNew
               block:observeBlock];

		[self.dl resume];
    }
	else {
        [self.item downloadURL:^(NSURL *downloadURL) {
            // work around for __autoreleasing ns progress
            NSProgress *ppp;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
            [request setValue:@"LivePhishApp/1.2 CFNetwork/672.1.15 Darwin/14.0.0"
           forHTTPHeaderField:@"User-Agent"];
            
            self.dl = [manager downloadTaskWithRequest:request
                                              progress:&ppp
                                           destination:destination
                                     completionHandler:completion];
            
            rootProgress = ppp;
            
            [kvo observe:ppp
                 keyPath:@"fractionCompleted"
                 options:NSKeyValueObservingOptionNew
                   block:observeBlock];
            
        	[self.dl resume];
        }];
	}
}

- (void)start {
	self.state = PHODDownloadStateDownloading;
	
	[self download];
}

- (void)cancelDownload {
	self.state = PHODDownloadStateCancelled;

	[self.dl cancel];

	[self cancel];
}

- (BOOL)isExecuting {
	return self.state == PHODDownloadStateDownloading;
}

- (BOOL)isFinished {
	return self.state == PHODDownloadStateDone ||
		   self.state == PHODDownloadStateCancelled ||
		   self.state == PHODDownloadStateFailed;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)setState:(PHODDownloadState)state {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	
    _state = state;
	
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];

}

@end
