//
//  PhishNetNewsItem.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetNewsItem.h"

@implementation PhishNetNewsItem

+ (JSONKeyMapper *)keyMapper {
	return [JSONKeyMapper.alloc initWithDictionary:@{
													 @"newsid": @"id",
													 @"postedby": @"author",
													 @"title": @"title",
													 @"pubdate": @"dateString",
													 @"txt": @"postHTML",
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

- (NSURL *)URL {
	return [NSURL URLWithString: [NSString stringWithFormat:@"http://m.phish.net/news.php?newsid=%@", self.id]];
}

@end
