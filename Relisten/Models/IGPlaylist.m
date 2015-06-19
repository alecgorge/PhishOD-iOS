//
//  IGPlaylist.m
//  iguana
//
//  Created by Manik Kalra on 11/30/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGPlaylist.h"

@implementation IGPlaylist

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
	if ([propertyName isEqualToString:@"count"]) {
		return YES;
	}
	
	return [super propertyIsOptional:propertyName];
}

@end
