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
#import "AGQueue.h"

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

- (NSURL *)downloadURL {
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

- (NSURL *)downloadURL {
    return self.track.mp3;
}

- (void)cache {
    [self.show cache];
}

@end

@interface PHODDownloaderCallbackContainer : NSObject

@property (nonatomic) NSObject *observer;
@property (nonatomic, copy) void (^progress)(int64_t, int64_t);
@property (nonatomic, copy) void (^success)(NSURL *);
@property (nonatomic, copy) void (^failure)(NSError *);

@end

@interface PHODDownloader ()

@property (nonatomic, readonly) NSString *cacheDir;
@property (nonatomic, readonly) TCBlobDownloadManager *manager;
@property (atomic) NSMutableDictionary<NSNumber *, NSMutableArray<PHODDownloaderCallbackContainer *> *> *callbacks;
@property (nonatomic) AGQueue<PHODDownloadItem *> *queue;

@end

@implementation PHODDownloader

- (id)init {
	if (self = [super init]) {
        _maxConcurrentDownloads = 2;
        
        _manager = [TCBlobDownloadManager.alloc initWithConfig:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"phod"]];
        _manager.startImmediatly = NO;
        
        _callbacks = NSMutableDictionary.dictionary;
        
        _downloading = NSMutableArray.array;
        _queue = AGQueue.new;
	}
	return self;
}

- (NSMutableArray<PHODDownloadItem *> *)downloadQueue {
    return self.queue.queue;
}

- (void)addDownloadObserver:(NSObject *)observer
            forDownloadItem:(PHODDownloadItem *)item
                   progress:(void (^)(int64_t, int64_t))progress
                    success:(void (^)(NSURL *))success
                    failure:(void (^)(NSError *))failure {
    [self addDownloadObserver:observer
                        forId:item.id
                     progress:progress
                      success:success
                      failure:failure];
}

- (void)addDownloadObserver:(NSObject *)observer
                      forId:(NSInteger)eyed
                   progress:(void (^)(int64_t, int64_t))progress
                    success:(void (^)(NSURL *))success
                    failure:(void (^)(NSError *))failure {
    PHODDownloaderCallbackContainer *cbc = PHODDownloaderCallbackContainer.new;
    cbc.progress = progress;
    cbc.success = success;
    cbc.failure = failure;
    cbc.observer = observer;

    NSNumber *num = @(eyed);
    
    if(!self.callbacks[num]) {
        self.callbacks[num] = NSMutableArray.new;
    }
    
    [self.callbacks[num] addObject:cbc];
}

- (void)removeDownloadObserver:(NSObject *)observer
                         forId:(NSInteger)eyed {
    NSNumber *num = @(eyed);
    
    NSMutableArray<PHODDownloaderCallbackContainer *> *toRemove = NSMutableArray.array;
    for(PHODDownloaderCallbackContainer *cbc in self.callbacks[num]) {
        if(cbc.observer == observer) {
            [toRemove addObject:cbc];
        }
    }
    
    for(PHODDownloaderCallbackContainer *cbc in toRemove) {
        [self.callbacks[num] removeObject:cbc];
    }
}

- (void)removeDownloadObserver:(NSObject *)observer forDownloadItem:(PHODDownloadItem *)item {
    [self removeDownloadObserver:observer
                           forId:item.id];
}

- (void)triggerProgress:(int64_t)done
                ofTotal:(int64_t)total
                forItem:(PHODDownloadItem *)item {
    NSNumber *num = @(item.id);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(PHODDownloaderCallbackContainer *cbc in self.callbacks[num]) {
            cbc.progress(done, total);
        }
    });
}

- (void)triggerSuccess:(NSURL *)url
               forItem:(PHODDownloadItem *)item {
    NSNumber *num = @(item.id);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(PHODDownloaderCallbackContainer *cbc in self.callbacks[num]) {
            cbc.success(url);
        }
        
        [self.delegate downloader:self
                     itemSucceded:item];

        [self removeDownloadingItem:item.id];
    });
}

- (void)triggerError:(NSError *)err
             forItem:(PHODDownloadItem *)item {
    NSNumber *num = @(item.id);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(PHODDownloaderCallbackContainer *cbc in self.callbacks[num]) {
            cbc.failure(err);
        }
        
        [self.delegate downloader:self
                       itemFailed:item];

        [self removeDownloadingItem:item.id];
    });
}

- (void)removeDownloadingItem:(NSInteger)eyed {
    NSNumber *num = @(eyed);
    
    self.callbacks[num] = NSMutableArray.array;
    
    for (PHODDownloadItem *i in self.downloading.copy) {
        if(i.id == eyed) {
            [self.downloading removeObject:i];
        }
    }
    
    [self startIfPossible];
}

- (void)startIfPossible {
    while(self.downloading.count < self.maxConcurrentDownloads) {
        PHODDownloadItem *i = [self.queue dequeue];
        
        [self.downloading addObject:i];
        
        [i.blob resume];

        [self.delegate downloader:self
                      itemStarted:i];
    }
}

- (TCBlobDownload *)downloadItem:(PHODDownloadItem *)item {
    NSString *path = [[item.class cacheDir] stringByAppendingPathComponent:item.cachePath];
    TCBlobDownload *blob = [self.manager downloadFileAtURL:item.downloadURL
                                               toDirectory:[NSURL fileURLWithPath:path.stringByDeletingLastPathComponent
                                                                      isDirectory:YES]
                                                  withName:path.lastPathComponent
                                               progression:^(float per, int64_t done, int64_t total) {
                                                   [self triggerProgress:done
                                                                 ofTotal:total
                                                                 forItem:item];
                                               }
                                                completion:^(NSError * _Nullable err, NSURL * _Nullable url) {
                                                    if(err) {
                                                        [self triggerError:err
                                                                   forItem:item];
                                                        return;
                                                    }
                                                    
                                                    [self triggerSuccess:url
                                                                 forItem:item];
                                                }];
    
    item.blob = blob;
    
    [self.queue enqueue:item];
    [self startIfPossible];
    
    return blob;
}

- (PHODDownloadItem *)findItemForItemIdInQueue:(NSInteger)track {
    id i = [self.downloading detect:^BOOL(PHODDownloadItem *object) {
        return object.id == track;
    }];
    
    if(i) return i;
    
	return [self.downloadQueue detect:^BOOL(PHODDownloadItem *op) {
		return op.id == track;
	}];
}

- (BOOL)isTrackDownloadedOrQueued:(NSInteger)track {
	return [self findItemForItemIdInQueue:track] != nil;
}

- (CGFloat)progressForTrack:(NSInteger)track {
    TCBlobDownload *blob = [self findItemForItemIdInQueue:track].blob;
	
	if(!blob) {
		return 0.0f;
	}
	
	return blob.progress;
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

- (PhishinDownloadItem *)downloadTrack:(PhishinTrack *)track
                                  inShow:(PhishinShow *)show {
    PhishinDownloadItem *i = [PhishinDownloadItem.alloc initWithTrack:track
                                                              andShow:show];

    [self downloadItem:i];
    
    return i;
}

@end

