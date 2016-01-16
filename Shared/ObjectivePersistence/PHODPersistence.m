//
//  PHODPersistence.m
//  PhishOD
//
//  Created by Alec Gorge on 7/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODPersistence.h"

#import <FCFileManager/FCFileManager.h>

@interface PHODPersistence ()

@property (atomic) NSMutableDictionary *memoryCache;
@property (nonatomic) dispatch_semaphore_t memoryLock;

@end

@implementation PHODPersistence

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id shared = nil;
    dispatch_once(&onceToken, ^{
        NSString *path = [FCFileManager pathForDocumentsDirectoryWithPath:@"persisted_objects"];
        shared = [PHODPersistence.alloc initWithStoragePath:path];
    });
    return shared;
}

- (instancetype)initWithStoragePath:(NSString *)path {
    if (self = [super init]) {
        _path = path;
        [FCFileManager createDirectoriesForPath:self.path];
        
//        self.memoryLock = dispatch_semaphore_create(1L);
        self.memoryCache = @{}.mutableCopy;
    }
    return self;
}

- (void)cullMemory {
//    dispatch_semaphore_wait(self.memoryLock, DISPATCH_TIME_FOREVER);
    
    while(self.memoryCache.count > 25) {
        [self.memoryCache removeObjectForKey:self.memoryCache.allKeys[0]];
    }
    
//    dispatch_semaphore_signal(self.memoryLock);
}

- (void)flushKeyToDisk:(NSString *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
        id<NSCoding> obj = self.memoryCache[key];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        
        [data writeToFile:[self pathForKey:key]
               atomically:YES];
        
        [self cullMemory];
    });
}

- (NSString *)pathForKey:(NSString *)key {
    return [self.path stringByAppendingPathComponent:key];
}

- (void)setObject:(id<NSCoding>)obj
           forKey:(NSString *)key {
    self.memoryCache[key] = obj;
    
    [self flushKeyToDisk:key];
}

- (id)objectForKey:(NSString *)key {
    id<NSCoding> obj = self.memoryCache[key];
    if (obj != nil) {
        return obj;
    }
    
    NSString *path = [self pathForKey:key];
    
    if([FCFileManager existsItemAtPath:path]) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    
    return obj;
}

@end
