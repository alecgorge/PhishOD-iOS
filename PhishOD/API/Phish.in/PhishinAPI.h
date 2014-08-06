//
//  PhishinAPI.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "PhishinYear.h"
#import "PhishinShow.h"
#import "PhishinEra.h"
#import "PhishinSong.h"
#import "PhishinTrack.h"
#import "PhishinTour.h"
#import "PhishinSearchResults.h"
#import "PhishinDownloader.h"
#import "PhishinPlaylist.h"
#import "PhishinPlaylistGroup.h"

@interface PhishinAPI : AFHTTPRequestOperationManager

+(instancetype)sharedAPI;

@property (nonatomic, readonly) PhishinDownloader *downloader;

-(void)eras:(void ( ^ ) ( NSArray *phishYears ))success
	failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)playlistForSlug:(NSString *)slug
			   success:(void ( ^ )( PhishinPlaylist *playlist ))success
			   failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)curatedPlaylists:(void (^)(NSArray *))success
                failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullYear:(PhishinYear *)year
		success:(void ( ^ ) ( PhishinYear * ))success
		failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullShow:(PhishinShow *)show
		success:(void ( ^ ) ( PhishinShow * ))success
		failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullTour:(PhishinTour *)tour
		success:(void ( ^ ) ( PhishinTour * ))success
		failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullVenue:(PhishinVenue*)venue
		 success:(void ( ^ ) ( PhishinVenue * ))success
		 failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullSong:(PhishinSong *)song
		success:(void ( ^ ) ( PhishinSong * ))success
		failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)randomShow:(void ( ^ ) ( PhishinShow * ))success
		  failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)tours:(void ( ^ ) ( NSArray * phishinTours ))success
	 failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)venues:(void ( ^ ) ( NSArray * ))success
	  failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)songs:(void ( ^ ) ( NSArray *phishSongs ))success
	 failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)search:(NSString*)searchTerm
	  success:(void ( ^ ) ( PhishinSearchResults * ))success
	  failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

@end
