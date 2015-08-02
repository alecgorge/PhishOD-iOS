//
//  PhishNetSetlist.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetSetlist.h"
#import "NSString+stripHTML.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>

@implementation PhishNetSetlist

@synthesize setlistHTML;
@synthesize setlistNotes;
@synthesize rating;
@synthesize ratingCount;
@synthesize showId;

- (id)initWithJSON:(NSDictionary *)dict {
	if(self = [super init]) {
		self.showId = dict[@"showid"];
		self.setlistNotes = dict[@"setlistnotes"];
		self.setlistHTML = dict[@"setlistdata"];
		self.rating = @"0.00";
		self.ratingCount = @"0";
		self.reviews = @[];
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
