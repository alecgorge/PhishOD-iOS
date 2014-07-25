//
//  LivePhishCompleteContainer.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishCompleteContainer.h"

@implementation LivePhishSet
@end

@implementation LivePhishCompleteContainer

+ (NSDictionary *)keyMapperDict {
    return @{
             @"reviews.items": @"reviews",
             @"totalContainerRunningTime": @"runningTime",
             @"tracks": @"songs",
             @"notes": @"notes",
             @"videoURL": @"videoURL",
             @"videoTitle": @"videoTitle",
             @"venue": @"venue",
             @"artistName": @"artist",
             @"containerID": @"id",
             @"performanceDate": @"date",
             @"img.url": @"relativeImagePath",
             @"accessList": @"accessList",
             @"pageURL": @"relativePagePath"
             };
}

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *m = [super keyMapperDict];
    
    NSMutableDictionary *dict = [self keyMapperDict].mutableCopy;
    
    [dict addEntriesFromDictionary:m];
    
    return [JSONKeyMapper.alloc initWithDictionary:dict];
}

- (BOOL)hasVideo {
    return self.videoURL != nil;
}

- (BOOL)canStream {
    return self.accessList && self.accessList.count != 0;
}

- (NSArray<Ignore> *)sets {
    if(_sets == nil) {
        _sets = NSMutableArray.array;
        
        NSArray *setNames = [[self.songs valueForKeyPath:@"@distinctUnionOfObjects.set"] sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSNumber *setName in setNames) {
            NSMutableArray *songsInSet = NSMutableArray.array;
            
            NSInteger trackNum = 1;
            for (LivePhishSong *song in self.songs) {
                if(song.set == setName.integerValue) {
                    song.track = trackNum;
                    [songsInSet addObject:song];
                    trackNum++;
                }
                
            }
            
            LivePhishSet *set = LivePhishSet.alloc.init;
            set.songs = songsInSet;
            
            if(setNames.count == 1) {
                set.name = @"Tracks";
            }
            else if(setName == setNames.lastObject) {
                set.name = @"Encore";
            }
            else {
                set.name = [NSString stringWithFormat:@"Set %d", setName.intValue];
            }
            
            [(NSMutableArray*)_sets addObject:set];
        }
    }
    
    return _sets;
}

@end
