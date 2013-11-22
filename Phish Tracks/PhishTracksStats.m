//
//  PhishTracksStats.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStats.h"
#import "PhishTracksStatsPlayEvent.h"
#import "Configuration.h"
#import <FXKeychain/FXKeychain.h>

#define FAILURE_RESPONSE_BODY_JSON(error) ( \
	[[NSJSONSerialization JSONObjectWithData:  \
		[error.userInfo[@"NSLocalizedRecoverySuggestion"] dataUsingEncoding:NSUTF8StringEncoding]  \
	options:0                 \
	error:nil] mutableCopy]  \
)

#define STATS_LOG_API_ERROR(respJson) (CLSLog(@"[stats] api error. error_code=%@ message='%@'", respJson[@"error_code"], respJson[@"message"]))


@implementation PhishTracksStats

static PhishTracksStats *sharedPts;

+ (void)setupWithAPIKey:(NSString *)apiKey {
	sharedPts = [PhishTracksStats sharedInstance];
	sharedPts.apiKey = apiKey;
//	NSLog(@"[stats] stats loaded with apikey=%@ sessionkey=%@", [PhishTracksStats sharedInstance].apiKey, [PhishTracksStats sharedInstance].sessionKey);
//	[sharedPts setAuthHeader];
}

+ (PhishTracksStats*)sharedInstance {
	if (sharedPts != nil) {
		return sharedPts;
	}

    static dispatch_once_t once;
    dispatch_once(&once, ^ {
		NSLog(@"PhishTracksStats: configuration=%@ base_url=%@", [Configuration configuration], [Configuration statsApiBaseUrl]);
		sharedPts = [[self alloc] initWithBaseURL:[NSURL URLWithString: [Configuration statsApiBaseUrl]]];
		sharedPts.parameterEncoding = AFJSONParameterEncoding;
	});

    return sharedPts;
}

- (id)initWithBaseURL:(NSURL *)url {
	if(self = [super initWithBaseURL:url]) {
		self.username   = [FXKeychain defaultKeychain][@"phishtracksstats_username"];
		self.userId     = [[FXKeychain defaultKeychain][@"phishtracksstats_userid"] integerValue];
		self.sessionKey = [FXKeychain defaultKeychain][@"phishtracksstats_authtoken"];
		self.isAuthenticated = self.sessionKey != nil;

		[self setDefaultHeader:@"Accept" value:@"application/json"];
	}
	return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
	[self setAuthorizationHeaderWithUsername:self.apiKey password:(self.sessionKey ? self.sessionKey : @"")];
	return [super requestWithMethod:method path:path parameters:parameters];
}

//- (void)setAuthHeader {
//	[self setAuthorizationHeaderWithUsername:self.apiKey password:(self.sessionKey ? self.sessionKey : @"")];
//}

//- (NSString *)username {
//	return [FXKeychain defaultKeychain][@"phishtracksstats_username"];
//}

//- (void)setUsername:(NSString *)username {
//	[FXKeychain defaultKeychain][@"phishtracksstats_username"] = username;
//}

- (void)setLocalSessionWithUsername:(NSString *)username userId:(NSInteger)userId sessionKey:(NSString *)sessionKey
{
	self.isAuthenticated = YES;
	self.username = username;
	self.userId = userId;
	self.sessionKey = sessionKey;
	
	[FXKeychain defaultKeychain][@"phishtracksstats_username"] = username;
	[FXKeychain defaultKeychain][@"phishtracksstats_authtoken"] = sessionKey;
	[FXKeychain defaultKeychain][@"phishtracksstats_userid"] = [@(userId) stringValue];
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

- (void)checkSessionKey:(NSString *)sessionKey
{
//	@"check_session_key.json"
}

- (void)createSession:(NSString *)username password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *error))failure;
{
	[self postPath:@"sessions.json"
		parameters:@{ @"login": username, @"password": password }
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 201) {
				   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
				   [self setLocalSessionWithUsername:dict[@"username"] userId:[dict[@"user_id"] integerValue] sessionKey:dict[@"session_key"]];

				   if (success)
					   success();
			   }
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	       {
			   if (failure) {
				   NSMutableDictionary * respJson = FAILURE_RESPONSE_BODY_JSON(error);
				   [self clearLocalSession];
				   int errorCode = [respJson[@"error_code"] integerValue];

				   STATS_LOG_API_ERROR(respJson);

				   failure([NSError errorWithDomain:@"stats" code:errorCode userInfo:respJson]);
			   }
		   }];
}

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password success:(void (^)())success failure:(void (^)(NSError *))failure
{
	[self postPath:@"registrations.json"
		parameters:@{ @"user": @{ @"username": username, @"email": email, @"password": password } }
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
           {
			   if (operation.response.statusCode == 201) {
				   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
				   [self setLocalSessionWithUsername:dict[@"username"] userId:[dict[@"user_id"] integerValue] sessionKey:dict[@"session_key"]];

				   if (success)
					   success();
			   }
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error)
           {
			   if (failure) {
				   NSMutableDictionary * respJson = FAILURE_RESPONSE_BODY_JSON(error);
				   [self clearLocalSession];
				   int errorCode = [respJson[@"error_code"] integerValue];
				   STATS_LOG_API_ERROR(respJson);
				   failure([NSError errorWithDomain:@"stats" code:errorCode userInfo:respJson]);
			   }
		   }];

}

- (void)createPlayedTrack:(PhishinTrack *)track success:(void (^)())success failure:(void (^)(NSError *error))failure
{
	NSDictionary *params = @{ @"track": @{
									  @"id": [NSNumber numberWithInt: track.id],
									  @"slug": track.slug,
									  @"show_id": [NSNumber numberWithInt: track.show.id],
									  @"show_date": track.show.date },
							  @"streaming_site": @"phishin" };

	[self postPath:@"plays.json"
		parameters:params
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 201 && success)
				   success();
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	       {
			   if (failure) {
				   NSMutableDictionary * respJson = FAILURE_RESPONSE_BODY_JSON(error);
				   [respJson setObject:[NSNumber numberWithInt:operation.response.statusCode] forKey:@"http_status"];
				   int errorCode = [respJson[@"error_code"] integerValue];
				   STATS_LOG_API_ERROR(respJson);
				   failure([NSError errorWithDomain:@"stats" code:errorCode userInfo:respJson]);
			   }
		   }];
}

- (void)statsHelperWithPath:(NSString *)path statsQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(NSError *))failure
{
	NSDictionary *params = [statsQuery asParams];
	
	[self postPath:path
		parameters:params
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 200 && success) {
				   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
				   PhishTracksStatsQueryResults *result = [[PhishTracksStatsQueryResults alloc] initWithDict:dict];
				   success(result);
			   }
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	       {
			   if (failure) {
				   NSMutableDictionary * respJson = FAILURE_RESPONSE_BODY_JSON(error);
				   [respJson setObject:[NSNumber numberWithInt:operation.response.statusCode] forKey:@"http_status"];
				   int errorCode = [respJson[@"error_code"] integerValue];
				   STATS_LOG_API_ERROR(respJson);
				   failure([NSError errorWithDomain:@"stats" code:errorCode userInfo:respJson]);
			   }
		   }];

}

- (void)userStatsWithUserId:(NSInteger)userId statsQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(NSError *))failure
{
	[self statsHelperWithPath:[NSString stringWithFormat:@"users/%@/plays/stats.json", [@(userId) stringValue]]
				   statsQuery:statsQuery
					  success:success
					  failure:failure];
}

- (void)globalStatsWithQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(NSError *))failure
{
	[self statsHelperWithPath:@"plays/stats.json"
				   statsQuery:statsQuery
					  success:success
					  failure:failure];
}

- (void)playHistoryHelperWithPath:(NSString *)path limit:(NSInteger)limit offset:(NSInteger)offset
        success:(void (^)(NSArray *playEvents))success failure:(void (^)(NSError *))failure
{
	[self  getPath:path
		parameters:@{ @"limit": [NSNumber numberWithInteger:limit], @"offset": [NSNumber numberWithInteger:offset] }
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 200 && success) {
				   NSArray *playEvents = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

				   playEvents = Underscore.array(playEvents).map(^ PhishTracksStatsPlayEvent *(NSDictionary *playEvenDict) {
					   return [[PhishTracksStatsPlayEvent alloc] initWithDict:playEvenDict];
				   }).unwrap;

				   success(playEvents);
			   }
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error)
	       {
			   if (failure) {
				   NSMutableDictionary * respJson = FAILURE_RESPONSE_BODY_JSON(error);
				   [respJson setObject:[NSNumber numberWithInt:operation.response.statusCode] forKey:@"http_status"];
				   int errorCode = [respJson[@"error_code"] integerValue];
				   STATS_LOG_API_ERROR(respJson);
				   failure([NSError errorWithDomain:@"stats" code:errorCode userInfo:respJson]);
			   }
		   }];
}

- (void)userPlayHistoryWithUserId:(NSInteger)userId limit:(NSInteger)limit offset:(NSInteger)offset
        success:(void (^)(NSArray *playEvents))success failure:(void (^)(NSError *))failure
{
	[self playHistoryHelperWithPath:[NSString stringWithFormat:@"users/%@/plays.json", [@(userId) stringValue]]
							  limit:limit
							 offset:offset
							success:success
							failure:failure];
}

- (void)globalPlayHistoryWithLimit:(NSInteger)limit offset:(NSInteger)offset
        success:(void (^)(NSArray *playEvents))success failure:(void (^)(NSError *))failure
{
	[self playHistoryHelperWithPath:@"plays.json"
							  limit:limit
							 offset:offset
							success:success
							failure:failure];
}

@end
