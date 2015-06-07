//
//  PhishNetTopShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetTopShow.h"

@implementation PhishNetTopShow

@synthesize rating;
@synthesize ratingCount;

- (NSURL *)albumArt {
	NSString *mediaDomain = [NSUserDefaults.standardUserDefaults objectForKey:@"media_domain"];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/album_art/ph%@.jpg", mediaDomain, self.showDate]];
}

- (NSString *)displayText {
	return self.showDate;
}

- (NSString *)displaySubtext {
	return [NSString stringWithFormat:@"%@ (%@ votes)", self.rating, self.ratingCount];
}

@end
