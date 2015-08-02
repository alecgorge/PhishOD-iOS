//
//  PhishinTrack.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhishinShow;
@class PhishNetJamChartEntry;
@class PhishinDownloader;
@class PHODDownloader;
@class PHODDownloadItem;
@class MPMediaItemArtwork;

@protocol PHODGenericTrack <NSObject>

- (MPMediaItemArtwork *)artwork;

- (NSString *)title;
- (NSTimeInterval)duration;
- (NSInteger)id;
- (NSInteger)track;

- (PHODDownloader *)downloader;

- (BOOL)isCacheable;
- (BOOL)isCached;
- (BOOL)isDownloadingOrQueued;
- (NSURL *)cachedFile;
- (PHODDownloadItem *)downloadItem;

@end

@interface PhishinTrack : NSObject <PHODGenericTrack, NSCoding>

- (instancetype)initWithDictionary:(NSDictionary*)dict andShow:(PhishinShow*)show;

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *title;
@property (nonatomic) NSInteger position;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSString *set;
@property (nonatomic) NSInteger likes_count;
@property (nonatomic) NSString *show_date;
@property (nonatomic) NSInteger show_id;
@property (nonatomic) NSString *slug;
@property (nonatomic) NSURL *mp3;
@property (nonatomic) NSArray *song_ids;
@property (nonatomic) NSString *index;

@property (nonatomic, readonly) NSInteger track;

@property (nonatomic) PhishNetJamChartEntry *jamChartEntry;
@property (nonatomic) NSDate *date;

@property (nonatomic) PhishinShow *show;

- (NSString*)shareURLWithPlayedTime:(NSTimeInterval)elapsed;

@end
