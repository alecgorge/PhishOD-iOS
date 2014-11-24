//
//  PhishinAPI.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinAPI.h"

#import <EGOCache/EGOCache.h>

@implementation PhishinAPI

+ (instancetype)sharedAPI {
    static dispatch_once_t once;
    static PhishinAPI *sharedFoo;
    dispatch_once(&once, ^ {
        NSString *domain = [NSUserDefaults.standardUserDefaults objectForKey:@"api_domain"];
        
        if(!domain || domain.length == 0) {
            domain = @"phish.in";
        }
        
		sharedFoo = [self.alloc initWithBaseURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://%@/api/v1/", domain]]];
        
        sharedFoo.apiDomain = domain;
        sharedFoo.mp3Domain = [NSUserDefaults.standardUserDefaults objectForKey:@"mp3_domain"];
        
        if(!sharedFoo.mp3Domain || sharedFoo.mp3Domain.length == 0) {
            sharedFoo.mp3Domain = @"phish.in";
        }
	});
    return sharedFoo;
}

- (PhishinDownloader *)downloader {
	return PhishinDownloader.sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
	if (self = [super initWithBaseURL:url]) {
		self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
		
		[self.requestSerializer setValue:@"application/json"
					  forHTTPHeaderField:@"Accept"];
	}
	
	return self;
}

- (id)parseJSON:(id)data {
	return data;
}

- (void)eras:(void (^)(NSArray *))success
	 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    __block NSArray *cachedYears = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        cachedYears = (NSArray *)[EGOCache.globalCache objectForKey:@"eras"];
        
        if(cachedYears) {
            success(cachedYears);
        }
    });

    [self GET:@"eras"
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
		  
          [EGOCache.globalCache setObject:arr
                                   forKey:@"phishin.eras"];
          
          if(!cachedYears || (arr.count != cachedYears.count)) {
              success(arr);
          }
	  }
	  failure:failure];
}

-(void)playlistForSlug:(NSString *)slug
			   success:(void ( ^ )( PhishinPlaylist *playlist ))success
			   failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure {
	[self GET:[@"playlists/" stringByAppendingString:slug]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, NSDictionary *res) {
		  success([PhishinPlaylist.alloc initWithDictionary:res[@"data"]]);
	  }
	  failure:failure];
}

- (void)curatedPlaylists:(void (^)(NSArray *))success
                 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self GET:@"https://s3.amazonaws.com/phishod/playlists.json"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
          success([responseObject[@"playlist_groups"] map:^id(NSDictionary *object) {
              return [PhishinPlaylistGroup.alloc initWithDictionary:object];
          }]);
      }
      failure:failure];
}

- (void)years:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    __block NSArray *cachedYears = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        cachedYears = (NSArray *)[EGOCache.globalCache objectForKey:@"phishin.years"];
        
        if(cachedYears) {
            success(cachedYears);
        }
    });
    
	[self GET:@"years"
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
          NSArray *arr = [responseObject[@"data"] map:^id(id object) {
              PhishinYear *year = [[PhishinYear alloc] init];
              year.year = object;
              year.shows = @[];
              return year;
          }];
          
          [EGOCache.globalCache setObject:arr
                                   forKey:@"phishin.years"];
          
          if(!cachedYears || (arr.count != cachedYears.count)) {
              success(arr);
          }
	  }
	  failure:failure];
}

- (void)fullYear:(PhishinYear *)year
		 success:(void (^)(PhishinYear *))success
		 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	if (year && [year.year hasPrefix:@"Shows on "]) {
		[self onThisDay:success
				failure:failure];
		return;
	}
	
    __block PhishinYear *cachedYear = nil;
    if(year.year) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            cachedYear = [PhishinYear loadYearFromCacheForYear:year.year];
            
            if(cachedYear) {
                success(cachedYear);
            }
        });
    }

    [self GET:[@"years/" stringByAppendingString:year.year]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
		  PhishinYear *newYear = [[PhishinYear alloc] init];
		  newYear.year = year.year;
		  newYear.shows = [responseObject[@"data"] map:^id(id object) {
			  return [[PhishinShow alloc] initWithDictionary:object];
		  }].reverse;
          
          [newYear cache];
          
          if(![newYear isEqualToPhishinYear:cachedYear]) {
              success(newYear);
          }
	  }
	  failure:failure];
}

- (void)onThisDay:(void (^)(PhishinYear *))success
		  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	NSDateComponents *c = [NSCalendar.currentCalendar components:NSCalendarUnitMonth | NSCalendarUnitDay
														fromDate:NSDate.date];
	
	[self GET:[NSString stringWithFormat:@"shows-on-day-of-year/%02d-%02d", (int)c.month, (int)c.day]
   parameters:@{@"per_page": @99999, @"sort_attr": @"date"}
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
		  PhishinYear *newYear = [[PhishinYear alloc] init];
		  newYear.year = [NSString stringWithFormat:@"Shows on %d/%d", (int)c.month, (int)c.day];
		  newYear.shows = [[responseObject[@"data"] map:^id(id object) {
			  return [[PhishinShow alloc] initWithDictionary:object];
		  }] sortedArrayUsingComparator:^NSComparisonResult(PhishinShow *obj1, PhishinShow *obj2) {
			  return [obj2.date compare:obj1.date];
		  }];
		  
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
    
    __block PhishinShow *cachedShow = nil;
    if(show.date) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            cachedShow = [PhishinShow loadShowFromCacheForShowDate:show.date];
            
            if(cachedShow) {
                success(cachedShow);
            }
        });
    }
	
	[self GET:path
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
		  PhishinShow *show = [PhishinShow.alloc initWithDictionary:responseObject[@"data"]];
		  [show cache];
          
          if(![show isEqual:cachedShow]) {
              success(show);              
          }
	  }
	  failure:failure];
}

- (void)randomShow:(void (^)(PhishinShow *))success
		   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self GET:@"random-show"
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
	[self GET:[@"venues/" stringByAppendingFormat:@"%d", venue.id]
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
	[self GET:@"songs"
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
	[self GET:@"venues"
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
	[self GET:[@"songs/" stringByAppendingFormat:@"%ld", (long)song.id]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
		  success([[PhishinSong alloc] initWithDictionary:responseObject[@"data"]]);
	  }
	  failure:failure];
}

- (void)tours:(void (^)(NSArray *))success
	  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self GET:@"tours"
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
	[self GET:[@"tours/" stringByAppendingFormat:@"%d", tour.id]
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
	[self GET:[@"search/" stringByAppendingString: [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
   parameters:nil
	  success:^(AFHTTPRequestOperation *operation, id responseObject) {
		  responseObject = [self parseJSON:responseObject];
		  
		  success([[PhishinSearchResults alloc] initWithDictionary:responseObject[@"data"]]);
	  }
	  failure:failure];
}

@end
