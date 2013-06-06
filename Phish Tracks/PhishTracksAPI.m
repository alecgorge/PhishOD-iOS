//
//  PhishTracksAPI.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksAPI.h"

@implementation PhishTracksAPI

+ (PhishTracksAPI*)sharedAPI {
    static dispatch_once_t once;
    static PhishTracksAPI *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] initWithBaseURL:[NSURL URLWithString: @"http://www.phishtracks.com"]];
		[sharedFoo setDefaultHeader:@"Accept" value:@"application/json, text/javascript, */*; q=0.01"];
		[sharedFoo setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
	});
    return sharedFoo;
}

- (void)years:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"/"
	   parameters:@{}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
			  responseObject = [NSJSONSerialization JSONObjectWithData: responseObject
															   options: NSJSONReadingMutableContainers error: nil];
			  NSMutableArray *succ = [NSMutableArray array];
			  for (NSString *y in responseObject[@"years"]) {
				  [succ addObject:[[PhishYear alloc] initWithYear:y]];
			  }
			  
			  success(succ);
		  }
		  failure:failure];
}

- (void)songs:(void (^)(NSArray *))success
		   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"/songs"
	   parameters:@{}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
			  responseObject = [NSJSONSerialization JSONObjectWithData: responseObject
															   options: NSJSONReadingMutableContainers error: nil];
			  NSMutableArray *succ = [NSMutableArray array];
			  for (NSDictionary *y in responseObject) {
				  [succ addObject:[[PhishSong alloc] initWithDictionary:y]];
			  }
			  
			  success(succ);
		  }
		  failure:failure];
	
}

- (void)fullShow:(PhishShow *)show
		 success:(void (^)(PhishShow *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"/shows/" stringByAppendingString: show.showDate]
	   parameters:@{}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
			  responseObject = [NSJSONSerialization JSONObjectWithData: responseObject
															   options: NSJSONReadingMutableContainers error: nil];
			  success([[PhishShow alloc] initWithDictionary:responseObject]);
		  }
		  failure:failure];
}

- (void)fullYear:(PhishYear *)year
		 success:(void (^)(PhishYear *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"/shows"
	   parameters:@{@"year": year.year}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
			  responseObject = [NSJSONSerialization JSONObjectWithData: responseObject
															   options: NSJSONReadingMutableContainers error: nil];
			  success([[PhishYear alloc] initWithYear:year.year andShowsJSONArray:responseObject]);
		  }
		  failure:failure];
}

- (void)fullSong:(PhishSong *)song
		 success:(void (^)(PhishSong *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"/songs/" stringByAppendingString: song.slug]
	   parameters:@{}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
			  responseObject = [NSJSONSerialization JSONObjectWithData: responseObject
															   options: NSJSONReadingMutableContainers error: nil];
			  NSMutableArray *a = [NSMutableArray array];
			  for (NSDictionary *track in responseObject[@"tracks"]) {
				  [a addObject:[[PhishSong alloc] initWithDictionary: track]];
			  }
			  song.tracks = a;
			  
			  success(song);
		  }
		  failure:failure];
}

@end
