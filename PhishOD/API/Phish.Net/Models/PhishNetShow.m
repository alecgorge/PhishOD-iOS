//
//  PhishNetShow.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetShow.h"

@implementation PhishNetShow

+ (JSONKeyMapper *)keyMapper {
	return [JSONKeyMapper.alloc initWithDictionary:@{
													 @"showid": @"id",
													 @"showdate": @"dateString",
													 @"venuename": @"venueName",
													 @"city": @"city",
													 @"state": @"state",
													 @"country": @"country",
													 }];
}

- (NSString *)venue {
	return [NSString stringWithFormat:@"%@ in %@, %@", self.venueName, self.city, self.state];
}

- (NSURL *)albumArt {
	NSString *mediaDomain = [NSUserDefaults.standardUserDefaults objectForKey:@"media_domain"];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/album_art/ph%@.jpg", mediaDomain, self.dateString]];
}

- (NSString *)displayText {
	return self.dateString;
}

- (NSString *)displaySubtext {
	return [NSString stringWithFormat:@"%@, %@", self.city, self.state];
}

@end
