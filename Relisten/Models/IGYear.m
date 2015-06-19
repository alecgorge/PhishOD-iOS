//
//  IGYear.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGYear.h"

@implementation IGYear

+ (JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
	if ([propertyName isEqualToString:@"avgRating"]) {
		return YES;
	}
	
	return [super propertyIsOptional:propertyName];
}

@end
