//
//  PhishTracksStats.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStats.h"
#import "PhishTracksStatsPlayEvent.h"
#import "PhishTracksStatsFavorite.h"
#import "Configuration.h"
#import <FXKeychain/FXKeychain.h>

typedef enum {
    kStatsErrorUnparsableBody = 100
} PhishTracksStatsApiErrors;

@implementation PhishTracksStats

static PhishTracksStats *sharedPts;

#pragma mark -
#pragma mark Initialization

+ (void)setupWithAPIKey:(NSString *)apiKey {
	sharedPts = [PhishTracksStats sharedInstance];
	sharedPts.apiKey = apiKey;
	sharedPts.autoplayTracks = YES;

	[sharedPts.requestSerializer setAuthorizationHeaderFieldWithUsername:sharedPts.apiKey
																password:(sharedPts.sessionKey ? sharedPts.sessionKey : @"")];
	//	NSLog(@"[stats] stats loaded with apikey=%@ sessionkey=%@", [PhishTracksStats sharedInstance].apiKey, [PhishTracksStats sharedInstance].sessionKey);
}

+ (PhishTracksStats*)sharedInstance {
	if (sharedPts != nil) {
		return sharedPts;
	}
	
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
		NSLog(@"[stats] configuration=%@ base_url=%@", [Configuration configuration], [Configuration statsApiBaseUrl]);
		sharedPts = [[self alloc] initWithBaseURL:[NSURL URLWithString: [Configuration statsApiBaseUrl]]];
		sharedPts.requestSerializer = AFJSONRequestSerializer.serializer;
		
		sharedPts.responseSerializer.acceptableContentTypes = [sharedPts.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
		

	});
	
    return sharedPts;
}

- (id)initWithBaseURL:(NSURL *)url {
	if(self = [super initWithBaseURL:url]) {
		self.username   = [FXKeychain defaultKeychain][@"phishtracksstats_username"];
		self.userId     = [[FXKeychain defaultKeychain][@"phishtracksstats_userid"] integerValue];
		self.sessionKey = [FXKeychain defaultKeychain][@"phishtracksstats_authtoken"];
		self.isAuthenticated = self.sessionKey != nil;
		
		[self.requestSerializer setValue:@"application/json"
					  forHTTPHeaderField:@"Accept"];
	}
	return self;
}

#pragma mark -
#pragma mark Local Sessions

- (void)setLocalSessionWithUsername:(NSString *)username userId:(NSInteger)userId sessionKey:(NSString *)sessionKey
{
	self.isAuthenticated = YES;
	self.username = username;
	self.userId = userId;
	self.sessionKey = sessionKey;
	
	[FXKeychain defaultKeychain][@"phishtracksstats_username"] = username;
	[FXKeychain defaultKeychain][@"phishtracksstats_authtoken"] = sessionKey;
	[FXKeychain defaultKeychain][@"phishtracksstats_userid"] = [@(userId) stringValue];
	
	[self.requestSerializer setAuthorizationHeaderFieldWithUsername:self.apiKey
														   password:(self.sessionKey ? self.sessionKey : @"")];
}

- (void)clearLocalSession
{
	if (self.isAuthenticated == NO)
		return;
	
	self.isAuthenticated = NO;
	self.username = nil;
	self.userId = -1;
	self.sessionKey = nil;
	
	[[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_username"];
	[[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_authtoken"];
	[[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_userid"];
}

#pragma mark -
#pragma mark API Helpers

- (NSString *)nestedResourcePathWithUserId:(NSInteger)userId resourcePath:(NSString *)resourcePath
{
	return [NSString stringWithFormat:@"users/%@/%@", [@(userId) stringValue], resourcePath];
}

#pragma mark -
#pragma mark Response Handling

- (void)handleRequestFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error failureCallback:(void (^)(PhishTracksStatsError *))failure
{
	if (!failure)
		return;
	
	PhishTracksStatsError *statsError = nil;
	NSHTTPURLResponse *resp = operation.response;
	
	if (resp) {
		NSDictionary *responseDict = operation.responseObject;
        
        if (responseDict) {
            statsError = [PhishTracksStatsError errorWithStatsErrorDictionary:responseDict httpStatus:resp.statusCode];
            
            if (statsError.apiErrorCode == kStatsSessionRequired)
                [self clearLocalSession];
			//            dbug(@"[stats] api error. http_status=%ld api_error_code=%ld api_message='%@'",
			//                    (long)statsError.httpStatus, (long)statsError.apiErrorCode, statsError.apiErrorMessage);
        }
        else {
            statsError = [PhishTracksStatsError errorWithError:[NSError errorWithDomain:@"PhishTracks Stats" code:kStatsErrorUnparsableBody
																			   userInfo:@{ NSLocalizedDescriptionKey: @"Couldn't parse response body." }]];
        }
        dbug(@"[stats] api error. error=%@", statsError);
	}
	else {
		statsError = [PhishTracksStatsError errorWithError:error];
		dbug(@"[stats] non-api request error. response was null. error=%@", statsError);
	}
	
	failure(statsError);
}

- (id)parseJsonString:(NSString *)jsonString
{
	NSData *d = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	return [self parseResponseObject:d error:nil];
}

- (id)parseResponseObject:(id)responseObject error:(NSError *)error
{
	return responseObject;
//	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//	return dict;
}

#pragma mark -
#pragma mark Users

- (void)createSession:(NSString *)username password:(NSString *)password
			  success:(void (^)())success failure:(void (^)(PhishTracksStatsError *error))failure
{
	[self POST:@"sessions.json"
	parameters:@{ @"login": username, @"password": password }
	   success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success) {
			 NSError *error = nil;
			 NSDictionary *dict = [self parseResponseObject:responseObject error:error];
			 [self setLocalSessionWithUsername:dict[@"username"] userId:[dict[@"user_id"] integerValue] sessionKey:dict[@"session_key"]];
			 success();
		 }
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self clearLocalSession];
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password
				   success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self POST:@"registrations.json"
	parameters:@{ @"user": @{ @"username": username, @"email": email, @"password": password } }
	   success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success) {
			 NSError *error = nil;
			 NSDictionary *dict = [self parseResponseObject:responseObject error:error];
			 [self setLocalSessionWithUsername:dict[@"username"] userId:[dict[@"user_id"] integerValue] sessionKey:dict[@"session_key"]];
			 success();
		 }
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self clearLocalSession];
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

#pragma mark -
#pragma mark Play Events

- (void)createPlayedTrack:(PhishinTrack *)track
				  success:(void (^)())success
				  failure:(void (^)(PhishTracksStatsError *error))failure {
	NSDictionary *params = @{ @"play_event": @{
									  @"track_id": [NSNumber numberWithInt:(int)track.id],
									  @"track_slug": track.slug,
									  @"show_id": [NSNumber numberWithInt: track.show.id],
									  @"show_date": track.show.date,
									  @"streaming_site": @"phishin" } };
	
	[self POST:@"plays.json"
	parameters:params
	   success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success)
			 success();
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

#pragma mark -
#pragma mark Stats

- (void)statsHelperWithPath:(NSString *)path statsQuery:(PhishTracksStatsQuery *)statsQuery
					success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure
{
	NSDictionary *params = [statsQuery asParams];
	
	[self POST:path
	parameters:params
	   success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success) {
			 NSError *error = nil;
			 NSDictionary *dict = [self parseResponseObject:responseObject error:error];
			 PhishTracksStatsQueryResults *result = [[PhishTracksStatsQueryResults alloc] initWithDictionary:dict];
			 success(result);
		 }
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
	
}

- (void)userStatsWithUserId:(NSInteger)userId statsQuery:(PhishTracksStatsQuery *)statsQuery
					success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self statsHelperWithPath:[self nestedResourcePathWithUserId:userId resourcePath:@"plays/stats.json"]
				   statsQuery:statsQuery
					  success:success
					  failure:failure];
}

- (void)globalStatsWithQuery:(PhishTracksStatsQuery *)statsQuery
					 success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self statsHelperWithPath:@"plays/stats.json"
				   statsQuery:statsQuery
					  success:success
					  failure:failure];
}

#pragma mark -
#pragma mark Play History

- (void)playHistoryHelperWithPath:(NSString *)path limit:(NSInteger)limit offset:(NSInteger)offset
						  success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self  GET:path
	parameters:@{ @"limit": [NSNumber numberWithInteger:limit], @"offset": [NSNumber numberWithInteger:offset] }
	   success:^(AFHTTPRequestOperation *operation, NSArray *playEvents)
	 {
		 if (success) {
			 playEvents = [playEvents map:^id(id object) {
				 return [[PhishTracksStatsPlayEvent alloc] initWithDictionary:object];
			 }];
			 
			 success(playEvents);
		 }
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

- (void)userPlayHistoryWithUserId:(NSInteger)userId limit:(NSInteger)limit offset:(NSInteger)offset
						  success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self playHistoryHelperWithPath:[self nestedResourcePathWithUserId:userId resourcePath:@"plays.json"]
							  limit:limit
							 offset:offset
							success:success
							failure:failure];
}

- (void)globalPlayHistoryWithLimit:(NSInteger)limit offset:(NSInteger)offset
						   success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self playHistoryHelperWithPath:@"plays.json"
							  limit:limit
							 offset:offset
							success:success
							failure:failure];
}

#pragma mark -
#pragma mark Favorites Helpers

- (void)getAllFavoritesHelper:(StatsFavoriteType)favoriteType resourcePath:(NSString *)path userId:(NSInteger)userId
                      success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self GET:[self nestedResourcePathWithUserId:userId resourcePath:path]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success) {
			 NSError *error = nil;
			 NSArray *favorites = [self parseResponseObject:responseObject error:error];
			 
			 favorites = [favorites map:^id(id object) {
				 return [[PhishTracksStatsFavorite alloc] initWithDictionary:object andType:favoriteType];
			 }];
			 
			 success(favorites);
		 }
	 }
	  failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

- (void)createUserFavoriteHelper:(StatsFavoriteType)favoriteType resourcePath:(NSString *)path userId:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite
                         success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self POST:[self nestedResourcePathWithUserId:userId resourcePath:path]
	parameters:[favorite asDictionary]
	   success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success) {
			 NSError *error = nil;
			 NSDictionary *favDict = [self parseResponseObject:responseObject error:error];
			 PhishTracksStatsFavorite *fav = [[PhishTracksStatsFavorite alloc] initWithDictionary:favDict andType:favoriteType];
			 success(fav);
		 }
	 }
	   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}

- (void)destroyUserFavoriteHelper:(NSString *)resourceName userId:(NSInteger)userId favoriteId:(NSInteger)favoriteId
                          success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self DELETE:[self nestedResourcePathWithUserId:userId resourcePath:[NSString stringWithFormat:@"%@/%ld.json", resourceName, (long)favoriteId]]
	  parameters:nil
		 success:^(AFHTTPRequestOperation *operation, id responseObject)
	 {
		 if (success)
			 success();
	 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 [self handleRequestFailure:operation error:error failureCallback:failure];
	 }];
}


#pragma mark Favorite Tracks

- (void)getAllUserFavoriteTracks:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self getAllFavoritesHelper:kStatsFavoriteTrack resourcePath:@"favorite_tracks.json" userId:userId success:success failure:failure];
}

- (void)createUserFavoriteTrack:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite
                        success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self createUserFavoriteHelper:kStatsFavoriteTrack resourcePath:@"favorite_tracks.json" userId:userId favorite:favorite success:success failure:failure];
    
}

- (void)destroyUserFavoriteTrack:(NSInteger)userId favoriteId:(NSInteger)favoriteId success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self destroyUserFavoriteHelper:@"favorite_tracks" userId:userId favoriteId:favoriteId success:success failure:failure];
}


#pragma mark Favorite Shows

- (void)getAllUserFavoriteShows:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self getAllFavoritesHelper:kStatsFavoriteShow resourcePath:@"favorite_shows.json" userId:userId success:success failure:failure];
}

- (void)createUserFavoriteShow:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite
                       success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self createUserFavoriteHelper:kStatsFavoriteShow resourcePath:@"favorite_shows.json" userId:userId favorite:favorite success:success failure:failure];
}

- (void)destroyUserFavoriteShow:(NSInteger)userId favoriteId:(NSInteger)favoriteId
                        success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self destroyUserFavoriteHelper:@"favorite_shows" userId:userId favoriteId:favoriteId success:success failure:failure];
}


#pragma mark Favorite Tours

- (void)getAllUserFavoriteTours:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self getAllFavoritesHelper:kStatsFavoriteTour resourcePath:@"favorite_tours.json" userId:userId success:success failure:failure];
}

- (void)createUserFavoriteTour:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite
                       success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self createUserFavoriteHelper:kStatsFavoriteTour resourcePath:@"favorite_tours.json" userId:userId favorite:favorite success:success failure:failure];
}

- (void)destroyUserFavoriteTour:(NSInteger)userId favoriteId:(NSInteger)favoriteId
                        success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self destroyUserFavoriteHelper:@"favorite_tours" userId:userId favoriteId:favoriteId success:success failure:failure];
}


#pragma mark Favorite Venues

- (void)getAllUserFavoriteVenues:(NSInteger)userId success:(void (^)(NSArray *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self getAllFavoritesHelper:kStatsFavoriteVenue resourcePath:@"favorite_venues.json" userId:userId success:success failure:failure];
}

- (void)createUserFavoriteVenue:(NSInteger)userId favorite:(PhishTracksStatsFavorite *)favorite
						success:(void (^)(PhishTracksStatsFavorite *))success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self createUserFavoriteHelper:kStatsFavoriteVenue resourcePath:@"favorite_venues.json" userId:userId favorite:favorite success:success failure:failure];
}

- (void)destroyUserFavoriteVenue:(NSInteger)userId favoriteId:(NSInteger)favoriteId
						 success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
{
    [self destroyUserFavoriteHelper:@"favorite_venues" userId:userId favoriteId:favoriteId success:success failure:failure];
}


@end
