//
//  IGArtists.m
//  iguana
//
//  Created by Manik Kalra on 10/14/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGArtist.h"

@implementation IGArtist

+ (JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
