//
//  PhishTracksStats.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
//#import "PhishTracksStatsPlay.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"

typedef enum {
	API_CLIENT_PERMISSION_FALSE = 1,
	API_KEY_REQUIRED       =  2,
	COULDNT_SAVE_PLAY      =  3,
	INVALID_USERNAME_PASSWORD = 4,
	MISSING_LOGIN_PARAM    =  5,
	SESSION_REQUIRED       = 6,
	SSL_REQUIRED           = 7,
	UNAUTHORIZED           = 8,
	USER_SAVE_FAILED       = 9,
	USER_NOT_SHARING_STATS = 10,
	USER_ID_NOT_FOUND      = 11,
	RECORD_LIMIT_TOO_HIGH  = 12,
	STATS_QUERY_INVALID    = 13,
	PARAM_MISSING          = 14
} StatsErrorCodes;

@interface PhishTracksStats : AFHTTPClient

+ (void)setupWithAPIKey:(NSString *)apiKey;
+ (PhishTracksStats *)sharedInstance;

@property NSString *apiKey;
@property NSString *sessionKey;
@property BOOL isAuthenticated;
@property NSString *username;
@property NSInteger userId;

- (void)checkSessionKey:(NSString *)sessionKey;

- (void)createSession:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)createPlayedTrack:(PhishinTrack *)track success:(void (^)())success failure:(void (^)(NSError *))failure;

- (void)clearLocalSession;

- (void)userStatsWithUserId:(NSInteger)userId statsQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(NSError *))failure;

- (void)globalStatsWithQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(NSError *))failure;

- (void)userPlayHistoryWithUserId:(NSInteger)userId limit:(NSInteger)limit offset:(NSInteger)offset
		success:(void (^)(NSArray *playEvents))success failure:(void (^)(NSError *))failure;
@end
