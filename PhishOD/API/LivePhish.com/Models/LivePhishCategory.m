//
//  LivePhishCategory.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishCategory.h"

@implementation LivePhishCategory

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"containerCategoryName": @"name",
                           @"containerCategoryID": @"id",
                           @"img.url": @"relativeImagePath"
                           };
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

- (NSURL *)imageURL {
    return [NSURL URLWithString:[@"https://s3.amazonaws.com/static.nugs.net" stringByAppendingString:self.relativeImagePath]];
}

@end
