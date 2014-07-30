//
//  PhishinAPI.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinAPI.h"

@implementation PhishinAPI

+ (instancetype)sharedAPI {
    static dispatch_once_t once;
    static PhishinAPI *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] initWithBaseURL:[NSURL URLWithString: @"http://phish.in/api/v1/"]];
		[sharedFoo setDefaultHeader:@"Accept" value:@"application/json"];
	});
    return sharedFoo;
}

- (id)parseJSON:(id)data {
	return [NSJSONSerialization JSONObjectWithData: data
										   options: NSJSONReadingMutableContainers
											 error: nil];
}

- (void)eras:(void (^)(NSArray *))success
	 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"eras"
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  NSMutableArray *arr = [NSMutableArray array];
			  responseObject = [self parseJSON:responseObject][@"data"];
			  
			  for (NSString *eraName in [[responseObject allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
				  PhishinEra *era = [[PhishinEra alloc] initWithName:eraName
															andYears:[responseObject[eraName] map:^id(id object) {
					  PhishinYear *year = [[PhishinYear alloc] init];
					  year.year = object;
					  year.shows = @[];
					  return year;
				  }]];

				  [arr addObject: era];
			  }
			  
			  success(arr);
		  }
		  failure:failure];
}

- (void)years:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"years"
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];

			  success([responseObject[@"data"] map:^id(id object) {
				  PhishinYear *year = [[PhishinYear alloc] init];
				  year.year = object;
				  year.shows = @[];
				  return year;
			  }]);
		  }
		  failure:failure];
}

- (void)fullYear:(PhishinYear *)year
		 success:(void (^)(PhishinYear *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"years/" stringByAppendingString:year.year]
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  PhishinYear *newYear = [[PhishinYear alloc] init];
			  newYear.year = year.year;
			  newYear.shows = [responseObject[@"data"] map:^id(id object) {
				  return [[PhishinShow alloc] initWithDictionary:object];
			  }].reverse;
			  
			  success(newYear);
		  }
		  failure:failure];
}

- (void)fullShow:(PhishinShow *)show
		 success:(void (^)(PhishinShow *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	NSString *path;
	if(show.id) {
		path = [@"shows/" stringByAppendingFormat:@"%d", show.id];
	}
	else {
		path = [@"show-on-date/" stringByAppendingFormat:@"%@", show.date];
	}
	
	[self getPath:path
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([[PhishinShow alloc] initWithDictionary:responseObject[@"data"]]);
		  }
		  failure:failure];
}

- (void)randomShow:(void (^)(PhishinShow *))success
		   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"random-show"
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([[PhishinShow alloc] initWithDictionary:responseObject[@"data"]]);
		  }
		  failure:failure];
}

- (void)fullVenue:(PhishinVenue *)venue
		  success:(void (^)(PhishinVenue *))success
		  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"venues/" stringByAppendingFormat:@"%d", venue.id]
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  venue.show_dates = responseObject[@"data"][@"show_dates"];
			  venue.show_ids = responseObject[@"data"][@"show_ids"];
			  
			  success(venue);
		  }
		  failure:failure];
}

- (void)songs:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"songs"
	   parameters:@{@"per_page": @99999, @"sort_attr": @"title"}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([responseObject[@"data"] map:^id(id object) {
				  return [[PhishinSong alloc] initWithDictionary:object];
			  }]);
		  }
		  failure:failure];
}

- (void)venues:(void (^)(NSArray *))success
	   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"venues"
	   parameters:@{@"per_page": @9999, @"sort_attr": @"name"}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([responseObject[@"data"] map:^id(id object) {
				  return [[PhishinVenue alloc] initWithDictionary:object];
			  }]);
		  }
		  failure:failure];
}

- (void)fullSong:(PhishinSong *)song
		 success:(void (^)(PhishinSong *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"songs/" stringByAppendingFormat:@"%ld", (long)song.id]
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([[PhishinSong alloc] initWithDictionary:responseObject[@"data"]]);
		  }
		  failure:failure];
}

- (void)tours:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:@"tours"
	   parameters:@{@"per_page": @9999, @"sort_attr": @"starts_on"}
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([responseObject[@"data"] map:^id(id object) {
				  return [[PhishinTour alloc] initWithDictionary:object];
			  }]);
		  }
		  failure:failure];
}

- (void)fullTour:(PhishinTour *)tour
		 success:(void (^)(PhishinTour *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"tours/" stringByAppendingFormat:@"%d", tour.id]
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([[PhishinTour alloc] initWithDictionary:responseObject[@"data"]]);
		  }
		  failure:failure];
}

- (void)search:(NSString *)searchTerm
	   success:(void (^)(PhishinSearchResults *))success
	   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self getPath:[@"search/" stringByAppendingString: [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
	   parameters:nil
		  success:^(AFHTTPRequestOperation *operation, id responseObject) {
			  responseObject = [self parseJSON:responseObject];
			  
			  success([[PhishinSearchResults alloc] initWithDictionary:responseObject[@"data"]]);
		  }
		  failure:failure];
}

@end
