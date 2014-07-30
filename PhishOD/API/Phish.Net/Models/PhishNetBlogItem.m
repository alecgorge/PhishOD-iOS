//
//  PhishNetBlogItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetBlogItem.h"

@implementation PhishNetBlogItem

+ (JSONKeyMapper *)keyMapper {
	return [JSONKeyMapper.alloc initWithDictionary:@{
													 @"id": @"id",
													 @"author": @"author",
													 @"title": @"title",
													 @"date": @"dateString",
													 @"link": @"URL",
													 }];
}

- (NSDate *)date {
	static NSDateFormatter *formatter = nil;
	
	if(formatter == nil) {
		formatter = NSDateFormatter.alloc.init;
		formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
	}
	
	return [formatter dateFromString:self.dateString];
}

@end
