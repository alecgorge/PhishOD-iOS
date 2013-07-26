//
//  PhishNetAPI.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AFHTTPClient.h"
#import "PhishNetSetlist.h"
#import "PhishNetReview.h"
#import "PhishNetTopShow.h"
#import "PhishSong.h"

#define PHISH_NET_API_KEY @"00000000000000000000"
#define PHISH_NET_PUB_KEY @"00000000000000000000"

@interface PhishNetAPI : AFHTTPClient {
	NSRegularExpression *findRating;
	NSRegularExpression *findVotes;
	NSRegularExpression *findTopRatings;
	
	NSRegularExpression *findIframe;
}

+(PhishNetAPI *)sharedAPI;

-(void)setlistForDate:(NSString *)date
			  success:(void ( ^ ) (PhishNetSetlist *))success
			  failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

-(void)jamsForSong:(PhishSong *)date
		   success:(void ( ^ ) (NSArray *dates))success;

-(void)reviewsForDate:(NSString *)date
			  success:(void ( ^ ) (NSArray *))success
			  failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

-(void)topRatedShowsWithSuccess:(void ( ^ ) (NSArray *))success
						failure:(void ( ^ ) ( AFHTTPRequestOperation *, NSError *))failure;

@end
