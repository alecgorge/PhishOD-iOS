//
//  PhishYear.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishYear.h"
#import "PhishShow.h"

@implementation PhishYear

@synthesize year;
@synthesize hasShowsLoaded;
@synthesize shows;

- (id)initWithYear:(NSString *)_year {
	return [self initWithYear:_year andShowsJSONArray:nil];
}

- (id)initWithYear:(NSString *)__year andShowsJSONArray:(NSArray *)arr {
	if(self = [super init]) {
		self.year = [__year description];
		self.hasShowsLoaded = NO;
		self.shows = @[];
		
		if(arr != nil) {
			self.hasShowsLoaded = YES;
			NSMutableArray *mShows = [NSMutableArray array];
			for(NSDictionary *dict in arr) {
				[mShows addObject: [[PhishShow alloc] initWithDictionary:dict]];
			}
			
			self.shows = mShows;
		}
	}
	return self;
}

@end
