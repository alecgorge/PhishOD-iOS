//
//  PhishShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishShow.h"
#import "PhishSet.h"

@implementation PhishShow

@synthesize showId;
@synthesize location;
@synthesize city;
@synthesize remastered;
@synthesize soundboard;
@synthesize showDate;

@synthesize hasSetsLoaded;
@synthesize sets;

- (id)initWithDictionary:(NSDictionary *)dict {
	if(self = [super init]) {
		NSArray *locParts = [dict[@"location"] componentsSeparatedByString:@" - "];
		
		self.showId = [dict[@"id"] intValue];
		self.location = locParts[0];
		self.city = locParts[1];
		self.remastered = [dict[@"remastered"] boolValue];
		self.soundboard = [dict[@"sbd"] boolValue];
		self.showDate = dict[@"show_date"];
		self.hasSetsLoaded = NO;
		self.sets = @[];
		
		if(dict[@"sets"] != nil) {
			self.hasSetsLoaded = YES;
			NSMutableArray *msets = [NSMutableArray array];
			for(NSDictionary *set in dict[@"sets"]) {
				[msets addObject:[[PhishSet alloc] initWithDictionary: set]];
			}
			self.sets = msets;
		}
	}
	return self;
}

@end
