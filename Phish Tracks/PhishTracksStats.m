//
//  PhishTracksStats.m
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStats.h"
#import <FXKeychain/FXKeychain.h>

@implementation PhishTracksStats

+ (PhishTracksStats*)sharedInstance {
    static dispatch_once_t once;
    static PhishTracksStats *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] initWithBaseURL:[NSURL URLWithString: @"http://www.phishtrackstats.com/api/"]];
	});
    return sharedFoo;
}

- (void)testUsername:(NSString *)username
			password:(NSString *)password
			callback:(BOOL (^)(void))cb {
	
}

@end
