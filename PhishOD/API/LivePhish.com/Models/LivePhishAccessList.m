//
//  LivePhishAccessList.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishAccessList.h"

@implementation LivePhishAccessList

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"passID": @"pass",
                           @"skuID": @"sku",
                           @"canPlay": @"canPlay",
                           };
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

@end
