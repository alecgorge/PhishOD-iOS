//
//  PhishTracksStats.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "PhishTracksStatsError.h"
#import "PhishTracksStatsQuery.h"
#import "PhishTracksStatsQueryResults.h"

typedef enum {
	kStatsApiClientPermissionFalse = 1,
	kStatsApiKeyRequired           = 2,
	kStatsCouldntSavePlay          = 3,
	kStatsInvalidUsernamePassword  = 4,
	kStatsMissingLoginParam        = 5,
	kStatsSessionRequired          = 6,
	kStatsSSLRequired              = 7,
	kStatsUnauthorized             = 8,
	kStatsUserSaveFailed           = 9,
	kStatsUserNotSharingStats      = 10,
	kStatsUserIdNotFound           = 11,
	kStatsRecordLimitTooHigh       = 12,
	kStatsStatsQueryInvalid        = 13,
	kStatsParamMissing             = 14
} StatsErrorCodes;

@interface PhishTracksStats : AFHTTPClient

+ (void)setupWithAPIKey:(NSString *)apiKey;
+ (PhishTracksStats *)sharedInstance;

@property NSString *apiKey;
@property NSString *sessionKey;
@property BOOL isAuthenticated;
@property NSString *username;
@property NSInteger userId;

//- (void)checkSessionKey:(NSString *)sessionKey;

- (void)createSession:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)createPlayedTrack:(PhishinTrack *)track success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)clearLocalSession;

- (void)userStatsWithUserId:(NSInteger)userId statsQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)globalStatsWithQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)userPlayHistoryWithUserId:(NSInteger)userId limit:(NSInteger)limit offset:(NSInteger)offset
		success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure;
@end
