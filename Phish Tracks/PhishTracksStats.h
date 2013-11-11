//
//  PhishTracksStats.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "PhishTracksStatsHistoryItem.h"

@interface PhishTracksStats : AFHTTPClient

+ (void)initWithAPIKey:(NSString *)apiKey;
+ (PhishTracksStats *)sharedInstance;

@property NSString *apiKey;
@property NSString *sessionKey;
@property BOOL isAuthenticated;
@property NSString *username;
@property NSInteger userId;

- (void)checkSessionKey:(NSString *)username
			password:(NSString *)password
			callback:(void (^)(BOOL success))cb
			 failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

- (BOOL)checkSessionKey;

//- (void)reauth:(void (^)(BOOL success))cb
//	   failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

- (void)signOut;

- (void)playedTrack:(PhishinTrack *)track
		   fromShow:(PhishinShow *)show
			success:(void (^)(void))cb
			failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

- (void)stats:(void (^)(NSDictionary *stats, NSArray *history))cb
	  failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

- (void)globalStats:(void (^)(NSDictionary *stats, NSArray *history))cb
			failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

@end
