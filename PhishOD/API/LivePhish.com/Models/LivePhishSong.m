//
//  LivePhishSong.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishSong.h"

@implementation LivePhishSong

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *dict = @{
                           @"songID": @"id",
                           @"songTitle": @"title",
                           @"discNum": @"disc",
                           @"trackNum": @"track",
                           @"setNum": @"set",
                           @"clipURL": @"clipURL",
                           @"trackID": @"trackId",
                           @"totalRunningTime": @"runningTime",
                           };
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

- (NSTimeInterval)duration {
    return self.runningTime;
}

@end
