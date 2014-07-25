//
//  LivePhishReview.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishReview.h"

@implementation LivePhishReview

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"reviewerName": @"author",
                           @"reviewDate": @"postedDateTimeString",
                           @"review": @"review",
                           };
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

@end
