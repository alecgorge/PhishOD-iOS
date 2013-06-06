//
//  PhishNetReview.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetReview.h"

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

@end
