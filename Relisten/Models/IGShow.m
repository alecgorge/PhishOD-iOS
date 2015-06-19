//
//  IGShow.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGShow.h"

@implementation IGShow

+ (JSONKeyMapper*)keyMapper {
	JSONKeyMapper *j = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
	return [JSONKeyMapper.alloc initWithJSONToModelBlock:^NSString *(NSString *keyName) {
		if ([keyName isEqualToString:@"description"]) {
			return @"showDescription";
		}
		return j.JSONToModelKeyBlock(keyName);
	}
										modelToJSONBlock:^NSString *(NSString *keyName) {
											return j.modelToJSONKeyBlock(keyName);
										}];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqualToString:@"recordingCount"]) {
        return YES;
    }
    
    return NO;
}

@end
