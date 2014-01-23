//
//  PhishTracksStats.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "PhishTracksStatsError.h"
#import "PhishTracksStatsFavorite.h"
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
@property BOOL autoplayTracks;

//- (void)checkSessionKey:(NSString *)sessionKey;

- (void)createSession:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password
                   success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)createPlayedTrack:(PhishinTrack *)track success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)clearLocalSession;

- (void)userStatsWithUserId:(NSInteger)userId statsQuery:(PhishTracksStatsQuery *)statsQuery
                    success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)globalStatsWithQuery:(PhishTracksStatsQuery *)statsQuery
                     success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)userPlayHistoryWithUserId:(NSInteger)userId limit:(NSInteger)limit offset:(NSInteger)offset
                          success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure;

- (void)globalPlayHistoryWithLimit:(NSInteger)limit offset:(NSInteger)offset
                           success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure;

#pragma mark -
#pragma mark Favorite Tracks

/*
 * GET /users/:user_id/favorite_tracks
 */
- (void)getAllUserFavoriteTracks:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * GET /users/:user_id/favorite_tracks/:id
 */
//- (void)getUserFavoriteTrack:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * POST /users/:user_id/favorite_tracks
 */
- (void)createUserFavoriteTrack:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * PUT /users/:user_id/favorite_tracks
 */
//- (void)updateUserFavoriteTrack:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * DELETE /users/:user_id/favorite_tracks
 */
- (void)destroyUserFavoriteTrack:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;


#pragma mark Favorite Shows

/*
 * GET /users/:user_id/favorite_shows
 */
- (void)getAllUserFavoriteShows:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * POST /users/:user_id/favorite_shows
 */
- (void)createUserFavoriteShow:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * DELETE /users/:user_id/favorite_shows
 */
- (void)destroyUserFavoriteShow:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;


#pragma mark Favorite Tours

/*
 * GET /users/:user_id/favorite_tours
 */
- (void)getAllUserFavoriteTours:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * POST /users/:user_id/favorite_tours
 */
- (void)createUserFavoriteTour:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * DELETE /users/:user_id/favorite_tours
 */
- (void)destroyUserFavoriteTour:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;


#pragma mark Favorite Venue

/*
 * GET /users/:user_id/favorite_venues
 */
- (void)getAllUserFavoriteVenues:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * POST /users/:user_id/favorite_venues
 */
- (void)createUserFavoriteVenue:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure;

/*
 * DELETE /users/:user_id/favorite_venues
 */
- (void)destroyUserFavoriteVenue:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure;

@end
