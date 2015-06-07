//
//  PHODHistory.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODHistory.h"

#import <EGOCache/EGOCache.h>

@implementation PHODHistory

static id sharedInstance;

+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [EGOCache.globalCache objectForKey:@"current.history"];
		if(sharedInstance == nil) {
			sharedInstance = [[self alloc] init];
		}
	});
	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		self.history = NSMutableOrderedSet.new;
	}
	return self;
}

- (BOOL)addShow:(PhishinShow *)show {
	NSInteger size = self.history.count;
	[self.history insertObject:show
					   atIndex:0];
	
	if(self.history.count > 20) {
		[self.history removeObjectAtIndex:self.history.count - 1];
		return YES;
	}
	
	return self.history.count - size > 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.history
				  forKey:@"history"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.history = [aDecoder decodeObjectForKey:@"history"];
	}
	sharedInstance = self;
	return self;
}

@end
