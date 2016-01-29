//
//  IGAPIClient.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <AFHTTPSessionManager.h>

#import "JSONValueTransformer+NSDateFromNSStringMilliseconds.h"

#import "IGYear.h"
#import "IGShow.h"
#import "IGVenue.h"
#import "IGArtist.h"
#import "IGUser.h"
#import "IGPlaylist.h"
#import "IGTodayArtist.h"

@interface IGAPIClient : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@property (nonatomic, strong) IGArtist *artist;

- (void)search:(NSString *)queryString success:(void (^)(NSArray *))success;

// an array of IGYear's
- (void)years:(void (^)(NSArray *))success;

- (void)artists:(void (^)(NSArray *))success;

- (void)playlists:(void (^)(NSArray *))success;

- (void)year:(NSUInteger)year success:(void (^)(IGYear *))success;

// an array of IGShow's
- (void)showsOn:(NSString *)displayDate success:(void (^)(NSArray *))success;

- (void)randomShow:(void (^)(NSArray *))success;

// venues
- (void)venues:(void (^)(NSArray *))success;

- (void)venue:(IGVenue *)venue success:(void (^)(IGVenue *))success;

- (void)topShows:(void (^)(NSArray *))success;

- (void)playTrack:(IGTrack *)track
           inShow:(IGShow *)show;

- (void)today:(void (^)(NSArray<IGTodayArtist *> *))success;

@end

@interface IGDownloadItem : PHODDownloadItem

@property (nonatomic, readonly) IGTrack *track;
@property (nonatomic, readonly) IGShow *show;

- (instancetype)initWithTrack:(IGTrack *)track
                      andShow:(IGShow *)show;

@end

@interface IGDownloader : PHODDownloader

+(instancetype)sharedInstance;

-(IGDownloadItem *)downloadTrack:(IGTrack *)track
                          inShow:(IGShow *)show;

@end
