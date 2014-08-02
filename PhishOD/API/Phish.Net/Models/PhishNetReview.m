//
//  PhishNetReview.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetReview.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>

@implementation PhishNetReview

- (id)initWithJSON:(NSDictionary *)dict {
	if(self = [super init]) {
		self.commentId = dict[@"commentid"];
		self.timestamp = [NSDate dateWithTimeIntervalSince1970: [dict[@"tstamp"] intValue]];
		self.author = dict[@"author"];
		self.review = dict[@"review"];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		[self autoDecode:aDecoder];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[self autoEncodeWithCoder:aCoder];
}

@end
