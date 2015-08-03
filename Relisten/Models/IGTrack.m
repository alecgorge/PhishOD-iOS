//
//  IGTrack.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGTrack.h"

#import "IGAPIClient.h"
#import "IGShow.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>

@implementation IGTrack

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super init]) {
//        [self autoDecode:aDecoder];
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [self autoEncodeWithCoder:aCoder
//                 andTestBlock:^BOOL(NSString *propName) {
//                    return ![propName isEqualToString:@"show"];
//                }];
//}

- (NSURL<Ignore> *)mp3 {
    return [NSURL URLWithString:self.file];
}

- (NSURL *)shareURLWithPlayedTime:(NSTimeInterval)elapsed {
    // http://relisten.net/grateful-dead/1983/8/27/drums
    NSCalendar *cal = NSCalendar.currentCalendar;
    
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                     fromDate:self.show.date];
    
	NSString *url = [NSString stringWithFormat:@"http://relisten.net/%@/%ld/%ld/%ld/%@",
                     IGAPIClient.sharedInstance.artist.slug,
                     comps.year,
                     comps.month,
                     comps.day,
                     self.slug];
    
	if(elapsed > 0) {
		url = [url stringByAppendingFormat:@"?t=%dm%ds", (int)floor(elapsed / 60), (int)((elapsed - floor(elapsed)) * 60)];
	}
    
	return [NSURL URLWithString:url];
}

- (NSTimeInterval)duration {
    return self.length;
}

- (BOOL)isCacheable {
    return YES;
}

- (BOOL)isCached {
    return self.downloadItem.isCached;
}

- (BOOL)isDownloadingOrQueued {
    return [self.downloader isTrackDownloadedOrQueued:self.downloadItem];
}

- (NSURL *)cachedFile {
    return self.downloadItem.cachedFile;
}

- (IGDownloader *)downloader {
    return IGDownloader.sharedInstance;
}

- (IGDownloadItem *)downloadItem {
    return [IGDownloadItem.alloc initWithTrack:self
                                       andShow:self.show];
}

@end
