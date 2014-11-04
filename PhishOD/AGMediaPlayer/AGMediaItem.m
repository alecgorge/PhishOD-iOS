//
//  AGMediaItem.m
//  iguana
//
//  Created by Alec Gorge on 3/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <NSObject-NSCoding/NSObject+NSCoding.h>

#import "AGMediaItem.h"

@implementation AGMediaItem

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self autoDecode:aDecoder];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (NSURL *)shareURLWithTime:(NSTimeInterval)seconds {
    return self.shareURL;
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:AGMediaItem.class]) return NO;
    
    return self.id == ((AGMediaItem*)object).id;
}

- (void)streamURL:(void (^)(NSURL *))callback {
    NSAssert(NO, @"this needs to be overridden");
}

- (BOOL)isDownloadingOrQueued {
    return NO;
}

- (BOOL)isCacheable {
	return NO;
}

- (BOOL)isCached {
	return NO;
}

- (PHODDownloadItem *)downloadItem {
    return nil;
}

- (PhishinDownloader *)downloader {
	return nil;
}

- (NSURL *)cachedFile {
	return nil;
}

- (MPMediaItemArtwork *)artwork {
	if (_artwork == nil && self.albumArt != nil) {
		_artwork = [MPMediaItemArtwork.alloc initWithImage:self.albumArt];
	}
	
	return _artwork;
}

@end
