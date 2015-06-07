//
//  PhishNetAPI.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetAPI.h"
#import "jQuery.h"

#import "PhishNetAuth.h"

@implementation PhishNetAPI

+ (PhishNetAPI*)sharedAPI {
    static dispatch_once_t once;
    static PhishNetAPI *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] initWithBaseURL:[NSURL URLWithString: @"https://api.phish.net/"]];
		
		sharedFoo.responseSerializer = AFHTTPResponseSerializer.serializer;
		
		sharedFoo.responseSerializer.acceptableContentTypes = [sharedFoo.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
	});
    return sharedFoo;
}

- (id)initWithBaseURL:(NSURL *)url {
	self = [super initWithBaseURL:url];
	if(self) {
		NSError *error;
		findRating = [NSRegularExpression regularExpressionWithPattern:@">Currently ([0-9.]+)/5<"
															   options:0
																 error:&error];
		findVotes  = [NSRegularExpression regularExpressionWithPattern:@"5 \\(([0-9]+) votes cast\\)<"
															   options:0
																 error:&error];
		findTopRatings  = [NSRegularExpression regularExpressionWithPattern:@"<td><a href=\"/setlists/\\?d=[0-9-]+\">([0-9-]+)</a></td>.*?<td>([0-9]+)</td>.*?<td>([0-9.]+)</td>"
																	options:NSRegularExpressionDotMatchesLineSeparators
																	  error:&error];
		
		findIframe = [NSRegularExpression regularExpressionWithPattern:@"src='(.*)'>"
															   options:0
																 error:&error];
		
		if(error) {
			dbug(@"%@", [error localizedDescription]);
		}
	}
	return self;
}

- (void)makeAPIRequest:(NSString *)method
		 withArguments:(NSDictionary*)args
			   success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject ))success
			   failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure {
	NSMutableDictionary *margs = [args ? args : @{} mutableCopy];
	margs[@"api"] = @"2.0";
	margs[@"method"] = method;
	margs[@"apikey"] = PHISH_NET_API_KEY;
	
	[self GET:@"/api.json"
   parameters:margs
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  //			  dbug(@"%@", [[NSString alloc] initWithData:responseObject
		  //												 encoding:NSUTF8StringEncoding]);
		  responseObject = [NSJSONSerialization JSONObjectWithData:responseObject
														   options:0
															 error:nil];
		  success(operation, responseObject);
	  }
	  failure:failure];
}

- (void)topRatedShowsWithSuccess:(void (^)(NSArray *))success
						 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self GET:@"http://phish.net/ratings"
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  NSString *page = [[NSString alloc] initWithData:responseObject
												 encoding:NSASCIIStringEncoding];
		  NSArray *matches = [findTopRatings matchesInString:page
													 options:0
													   range:NSMakeRange(0, [page length])];
		  
		  NSMutableArray *topShows = [[NSMutableArray alloc] initWithCapacity: matches.count];
		  for(NSTextCheckingResult *res in matches) {
			  PhishNetTopShow *show = [[PhishNetTopShow alloc] init];
			  show.showDate = [page substringWithRange:[res rangeAtIndex:1]];
			  show.rating = [page substringWithRange:[res rangeAtIndex:3]];
			  show.ratingCount = [page substringWithRange:[res rangeAtIndex:2]];
			  [topShows addObject:show];
		  }
		  
		  success(topShows);
	  }
	  failure:failure];
	
}

- (void)jamsForSong:(PhishinSong *)date
			success:(void (^)(NSArray *))success {
	[self GET:[NSString stringWithFormat:@"http://phish.net/jamcharts/song/%@", date.netSlug , nil]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  NSString *page = [[NSString alloc] initWithData:responseObject
												 encoding:NSASCIIStringEncoding];
		  
		  jQuery *$ = [jQuery.alloc initWithHTML:page
									   andScript:@"scrape_jams"];
		  
		  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		  formatter.dateFormat = @"yyyy-MM-dd";
		  
		  [$ start:^(NSError *err, NSArray *res) {
			  res = [res map:^id(NSDictionary *object) {
				  NSMutableDictionary *obj = object.mutableCopy;
				  obj[@"date"] = [formatter dateFromString:obj[@"date"]];
				  
				  return [PhishNetJamChartEntry.alloc initWithDictionary:obj];
			  }];
			  
			  success(res);
		  }];
	  }
	  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		  
	  }];
}

-(void)setlistForDate:(NSString *)date
			  success:(void (^)(PhishNetSetlist *setlist)) success
			  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.shows.setlists.get"
		   withArguments:@{@"showdate": date}
				 success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 PhishNetSetlist *set = [[PhishNetSetlist alloc] initWithJSON:responseObject[((NSArray*)responseObject).count - 1]];
					 
					 [self reviewsForDate:date
								  success:^(NSArray *reviews) {
									  set.reviews = reviews;
									  
									  [self GET:@"http://phish.net/setlists/"
									 parameters:@{@"showid": set.showId}
										success:^(AFHTTPRequestOperation *operation, id responseObject) {
											NSString *page = [[NSString alloc] initWithData:responseObject
																				   encoding:NSASCIIStringEncoding];
											NSTextCheckingResult *match = [findRating firstMatchInString:page
																								 options:0
																								   range:NSMakeRange(0, [page length])];
											
											NSTextCheckingResult *matca = [findVotes firstMatchInString:page
																								options:0
																								  range:NSMakeRange(0, [page length])];
											
											if(match) {
												set.rating = [page substringWithRange:[match rangeAtIndex:1]];
											}
											if(matca) {
												set.ratingCount = [page substringWithRange:[matca rangeAtIndex:1]];
											}
											
											success(set);
										}
										failure:failure];
								  }
								  failure:failure];
				 }
				 failure:failure];
}

- (void)reviewsForDate:(NSString *)date
			   success:(void (^)(NSArray *))success
			   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.reviews.query"
		   withArguments:@{@"showdate": date}
				 success:^(AFHTTPRequestOperation *operation, id responseObject) {
					 if([responseObject isKindOfClass:[NSDictionary class]]) {
						 success(@[]);
						 return;
					 }
					 NSArray *arr = (NSArray*)responseObject;
					 NSMutableArray *marr = [NSMutableArray arrayWithCapacity: arr.count];
					 for (NSDictionary *dictr in arr) {
						 [marr addObject:[[PhishNetReview alloc] initWithJSON:dictr]];
					 }
					 success(marr);
				 }
				 failure:failure];
	
}

- (void)news:(void (^)(NSArray *))success
	 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.news.get"
		   withArguments:nil
				 success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
					 success([responseObject.reverse map:^id(NSDictionary *object) {
						 NSError *err;
						 
						 PhishNetNewsItem *o = [PhishNetNewsItem.alloc initWithDictionary:object
																					error:&err];
						 
						 if (err) {
							 dbug(@"json error: %@", err);
						 }
						 
						 return o;
					 }].reverse);
				 }
				 failure:failure];
}

- (void)blog:(void (^)(NSArray *))success
	 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.blog.get"
		   withArguments:nil
				 success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
					 success([[responseObject.allValues map:^id(NSDictionary *object) {
						 NSError *err;
						 
						 PhishNetBlogItem *o = [PhishNetBlogItem.alloc initWithDictionary:object
																					error:&err];
						 
						 if (err) {
							 dbug(@"json error: %@", err);
						 }
						 
						 return o;
					 }] sortedArrayUsingComparator:^NSComparisonResult(PhishNetBlogItem *obj1, PhishNetBlogItem *obj2) {
						 return [obj2.id compare:obj1.id
										 options:0
										   range:NSMakeRange(0, obj2.id.length)];
					 }]);
				 }
				 failure:failure];
}

- (void)showsForCurrentUser:(void (^)(NSArray *))success
					failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.user.myshows.get"
		   withArguments:@{@"username": PhishNetAuth.sharedInstance.username}
				 success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
					 success([[responseObject reject:^BOOL(NSDictionary *object) {
						 return ![object[@"artist"] isEqualToString:@"1"];
					 }] map:^id(NSDictionary *object) {
						 NSError *err;
						 
						 PhishNetShow *o = [PhishNetShow.alloc initWithDictionary:object
																			error:&err];
						 
						 if (err) {
							 dbug(@"json error: %@", err);
						 }
						 
						 return o;
					 }].reverse);
				 }
				 failure:failure];
}

- (void)authorizeUsername:(NSString *)username
			 withPassword:(NSString *)password
				  success:(void (^)(BOOL, NSString *))success
				  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self makeAPIRequest:@"pnet.api.authorize"
		   withArguments:@{@"username": username, @"passwd": password}
				 success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
					 if ([responseObject[@"success"] boolValue]) {
						 success(YES, responseObject[@"authkey"]);
					 }
					 else {
						 success(NO, nil);
					 }
				 }
				 failure:failure];
}

@end
