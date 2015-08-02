//
//  PHODHistory.m
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODHistory.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

#import "PHODPersistence.h"

#import "IGAPIClient.h"

@implementation PHODHistory

static id sharedInstance;

+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [PHODPersistence.sharedInstance objectForKey:@"current.history"];
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

#ifdef IS_PHISH
- (BOOL)addShow:(PhishinShow *)show {
#else
- (BOOL)addShow:(IGShow *)show {
#endif
	if(show == nil) {
		return NO;
	}
	
	NSInteger size = self.history.count;
	[self.history insertObject:show
					   atIndex:0];
    
#ifdef IS_PHISH
    if(self.history.count > 20) {
        [self.history removeObjectAtIndex:self.history.count - 1];
#else
    NSArray *currentArtist = [self.history.array select:^BOOL(IGShow *object) {
        return IGAPIClient.sharedInstance.artist.id == object.ArtistId;
    }];
	
	if(currentArtist.count > 20) {
        [self.history removeObject:currentArtist[0]];
#endif
		return YES;
	}
	
	return self.history.count - size > 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.history.array
				  forKey:@"history"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.history = [NSMutableOrderedSet.alloc initWithArray:[aDecoder decodeObjectForKey:@"history"]];
	}
	return self;
}

@end
