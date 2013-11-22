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
		NSLog(@"[stats] configuration=%@ base_url=%@", [Configuration configuration], [Configuration statsApiBaseUrl]);
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

//		[self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
//			CLSLog(@"[stats] reachability status=%ld", (long)status);
//		}];
	}
	return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
	[self setAuthorizationHeaderWithUsername:self.apiKey password:(self.sessionKey ? self.sessionKey : @"")];
	return [super requestWithMethod:method path:path parameters:parameters];
}

- (id)parseResponseObject:(id)responseObject error:(NSError *)error
{
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
	return dict;
}

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

- (void)handleRequestFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error failureCallback:(void (^)(PhishTracksStatsError *))failure
{
	if (!failure)
		return;

	PhishTracksStatsError *statsError = nil;
	NSHTTPURLResponse *resp = operation.response;

	if (resp) {
		NSDictionary *responseDict = [self parseJsonString:operation.responseString];
		statsError = [PhishTracksStatsError errorWithStatsErrorDictionary:responseDict httpStatus:resp.statusCode];
		CLS_LOG(@"[stats] api error. http_status=%ld api_error_code=%ld api_message='%@'",
				 (long)statsError.httpStatus, (long)statsError.apiErrorCode, statsError.apiErrorMessage);
	}
	else {
		statsError = [PhishTracksStatsError errorWithError:error];
		CLS_LOG(@"[stats] non-api request error. response was null. error=%@", statsError);
	}

	failure(statsError);
}

- (id)parseJsonString:(NSString *)jsonString
{
	NSData *d = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	return [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
}

- (void)checkSessionKey:(NSString *)sessionKey
{
//	@"check_session_key.json"
}

- (void)createSession:(NSString *)username password:(NSString *)password
success:(void (^)())success failure:(void (^)(PhishTracksStatsError *error))failure
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
			   [self clearLocalSession];
			   [self handleRequestFailure:operation error:error failureCallback:failure];
		   }];
}

- (void)createRegistration:(NSString *)username email:(NSString *)email password:(NSString *)password
success:(void (^)())success failure:(void (^)(PhishTracksStatsError *))failure
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
			   [self clearLocalSession];
			   [self handleRequestFailure:operation error:error failureCallback:failure];
		   }];

}

- (void)createPlayedTrack:(PhishinTrack *)track success:(void (^)())success failure:(void (^)(PhishTracksStatsError *error))failure
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
			   [self handleRequestFailure:operation error:error failureCallback:failure];
		   }];
}

- (void)statsHelperWithPath:(NSString *)path statsQuery:(PhishTracksStatsQuery *)statsQuery
        success:(void (^)(PhishTracksStatsQueryResults *))success failure:(void (^)(PhishTracksStatsError *))failure
{
	NSDictionary *params = [statsQuery asParams];
	
	[self postPath:path
		parameters:params
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 200 && success) {
//				   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
				   NSError *error = nil;
				   NSDictionary *dict = [self parseResponseObject:responseObject error:error];
				   PhishTracksStatsQueryResults *result = [[PhishTracksStatsQueryResults alloc] initWithDict:dict];
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
	[self statsHelperWithPath:[NSString stringWithFormat:@"users/%@/plays/stats.json", [@(userId) stringValue]]
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

- (void)playHistoryHelperWithPath:(NSString *)path limit:(NSInteger)limit offset:(NSInteger)offset
        success:(void (^)(NSArray *playEvents))success failure:(void (^)(PhishTracksStatsError *))failure
{
	[self  getPath:path
		parameters:@{ @"limit": [NSNumber numberWithInteger:limit], @"offset": [NSNumber numberWithInteger:offset] }
		   success:^(AFHTTPRequestOperation *operation, id responseObject)
	       {
			   if (operation.response.statusCode == 200 && success) {
				   NSArray *playEvents = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

				   playEvents = [playEvents map:^id(id object) {
					   return [[PhishTracksStatsPlayEvent alloc] initWithDict:object];
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
	[self playHistoryHelperWithPath:[NSString stringWithFormat:@"users/%@/plays.json", [@(userId) stringValue]]
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

@end
