//
//  PhishTracksStats.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStats.h"
#import "Configuration.h"
#import <FXKeychain/FXKeychain.h>

@implementation PhishTracksStats

+ (PhishTracksStats*)sharedInstance {
    static dispatch_once_t once;
    static PhishTracksStats *sharedFoo;
    dispatch_once(&once, ^ {
		NSLog(@"PhishTracksStats: configuration=%@ base_url=%@", [Configuration configuration], [Configuration ptsApiBaseUrl]);
		sharedFoo = [[self alloc] initWithBaseURL:[NSURL URLWithString: [Configuration ptsApiBaseUrl]]];
		sharedFoo.parameterEncoding = AFJSONParameterEncoding;
	});
    return sharedFoo;
}

- (id)initWithBaseURL:(NSURL *)url {
	if(self = [super initWithBaseURL:url]) {
		self.authToken = [FXKeychain defaultKeychain][@"phishtracksstats_authtoken"];
		self.isAuthenticated = self.authToken != nil;
		self.userId = [[FXKeychain defaultKeychain][@"phishtracksstats_userid"] integerValue];
	}
	return self;
}

- (NSString *)username {
	return [FXKeychain defaultKeychain][@"phishtracksstats_username"];
}

- (void)setUsername:(NSString *)username {
	[FXKeychain defaultKeychain][@"phishtracksstats_username"] = username;
}

- (void)testUsername:(NSString *)username
			password:(NSString *)password
			callback:(void (^)(BOOL success))cb
			 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self postPath:@"users/sign_in.json"
		parameters:@{@"user_login": @{@"login": username, @"password": password}}
		   success:^(AFHTTPRequestOperation *operation, id responseObject) {
			   if(operation.response.statusCode == 201) {
				   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject
																		options:0
																		  error:nil];
				   
				   [FXKeychain defaultKeychain][@"phishtracksstats_username"] = username;
				   [FXKeychain defaultKeychain][@"phishtracksstats_password"] = password;
				   [FXKeychain defaultKeychain][@"phishtracksstats_authtoken"] = dict[@"auth_token"];
				   [FXKeychain defaultKeychain][@"phishtracksstats_userid"] = [dict[@"user_id"] stringValue];
				   
				   self.authToken = dict[@"auth_token"];
				   self.isAuthenticated = YES;
				   self.userId = [dict[@"user_id"] integerValue];
				   
				   cb(YES);
			   }
			   else {
				   self.isAuthenticated = NO;
				   cb(NO);
			   }
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			   self.isAuthenticated = NO;
			   cb(NO);
//			   failure(operation, error);
		   }];
}

- (void)reauth:(void (^)(BOOL))cb
	   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	if([FXKeychain defaultKeychain][@"phishtracksstats_username"] == nil
	|| [FXKeychain defaultKeychain][@"phishtracksstats_password"] == nil) {
		cb(NO);
		return;
	}
	[self testUsername:[FXKeychain defaultKeychain][@"phishtracksstats_username"]
			  password:[FXKeychain defaultKeychain][@"phishtracksstats_password"]
			  callback:cb
			   failure:failure];
}

- (void)signOut:(void (^)(BOOL))cb
		failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self deletePath:@"users/sign_out.json"
		  parameters:@{@"auth_token": self.authToken}
			 success:^(AFHTTPRequestOperation *operation, id responseObject) {
				 if(cb) cb(YES);
				 self.isAuthenticated = NO;
				 self.userId = 0;
				 self.username = nil;
				 
				 [[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_username"];
				 [[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_password"];
				 [[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_authtoken"];
				 [[FXKeychain defaultKeychain] removeObjectForKey:@"phishtracksstats_userid"];
			 }
			 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				 if(cb) cb(NO);
				 if(failure) failure(operation, error);
			 }];
}

- (void)_playedTrack:(PhishSong *)song
			fromShow:(PhishShow *)show
			 success:(void (^)(void))cb
			 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self postPath:[NSString stringWithFormat:@"played_tracks.json?auth_token=%@", self.authToken, nil]
		parameters:@{ @"played_track": @{
							  @"track_id": [NSNumber numberWithInt: song.trackId],
							  @"slug": song.slug,
							  @"show_id": [NSNumber numberWithInt: show.showId],
							  @"show_date": show.showDate } }
		   success:^(AFHTTPRequestOperation *operation, id responseObject) {
			   if(cb) cb();
		   }
		   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			   if(failure) failure(operation, error);
		   }];
}

- (void)playedTrack:(PhishSong *)song
		   fromShow:(PhishShow *)show
		   success:(void (^)(void))cb
			failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	if(self.isAuthenticated) {
		[self _playedTrack:song
				  fromShow:show
				   success:cb
				   failure:failure];
	}
	else {
		[self reauth:^(BOOL success) {
			if(success) {
				[self _playedTrack:song
						  fromShow:show
						   success:cb
						   failure:failure];
			}
		}
			 failure:failure];
	}
	
}

-(void)_stats:(void (^)(NSDictionary *stats, NSArray *history))cb
	  failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[NSString stringWithFormat:@"stats/users/%d.json", self.userId]
	   parameters:@{@"auth_token": self.authToken}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSDictionary *stats = [NSJSONSerialization JSONObjectWithData:responseObject
																	options:0
																	  error:nil];
			  
			  [self getPath:[NSString stringWithFormat:@"stats/users/%d/history.json", self.userId]
				 parameters:@{@"auth_token": self.authToken}
					success:^(AFHTTPRequestOperation *operation, id responseObject) {
						NSDictionary *history = [NSJSONSerialization JSONObjectWithData:responseObject
																				options:0
																				  error:nil];
						
						NSLog(@"%d", self.userId);
						NSMutableArray *his = [NSMutableArray array];
						for (NSDictionary *dict in history[@"user_history"]) {
							[his addObject:[[PhishTracksStatsHistoryItem alloc] initWithJSON: dict]];
						}
						
						cb(stats[@"user"][@"stats"], his);
					}
					failure:failure];
		  }
		  failure:failure];
}


- (void)stats:(void (^)(NSDictionary *, NSArray *))cb
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	if(self.isAuthenticated) {
		[self _stats:cb failure:failure];  
	}
	else {
		[self reauth:^(BOOL success) {
			if(success) {
				[self _stats:cb failure:failure];
			}
		}
			 failure:failure];
	}
}


-(void)_globalStats:(void (^)(NSDictionary *stats, NSArray *history))cb
			failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"stats/overall.json"
	   parameters:@{@"auth_token": self.authToken}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSDictionary *stats = [NSJSONSerialization JSONObjectWithData:responseObject
																	options:0
																	  error:nil];
			  
			  NSMutableArray *his = [NSMutableArray array];
			  for (NSDictionary *dict in stats[@"overall_stats"][@"top_tracks"]) {
				  [his addObject:[[PhishTracksStatsHistoryItem alloc] initWithJSON: dict]];
			  }
			  
			  cb(@{
				   @"play_count": stats[@"overall_stats"][@"play_count"],
				   @"total_time_formatted": stats[@"overall_stats"][@"total_time_formatted"]
				   }, his);
		  }
		  failure:failure];
}

- (void)globalStats:(void (^)(NSDictionary *, NSArray *))cb
			failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	if(self.isAuthenticated) {
		[self _globalStats:cb failure:failure];
	}
	else {
		[self reauth:^(BOOL success) {
			if(success) {
				[self _globalStats:cb failure:failure];
			}
		}
			 failure:failure];
	}
}

@end
