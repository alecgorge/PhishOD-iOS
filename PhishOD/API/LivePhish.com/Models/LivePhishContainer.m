//
//  LivePhishContainer.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishContainer.h"

@implementation LivePhishContainer

+ (NSDictionary *)keyMapperDict {
    return @{
             @"containerType": @"type",
             @"albumTitle": @"album",
             @"venue": @"venue",
             @"containerID": @"id",
             @"performanceDate": @"date",
             @"artistName": @"artist",
             @"img.url": @"relativeImagePath",
             @"pageURL": @"relativePagePath",
             @"containerInfo": @"containerInfo",
             };
}

+ (JSONKeyMapper *)keyMapper {
    return [JSONKeyMapper.alloc initWithDictionary:[self keyMapperDict]];
}

- (NSURL *)imageURL {
    if(!self.relativeImagePath) {
        return nil;
    }
    
    return [NSURL URLWithString:[@"https://s3.amazonaws.com/static.nugs.net" stringByAppendingString:self.relativeImagePath]];
}

- (NSURL *)livePhishPageURL {
    if(!self.relativePagePath) {
        return nil;
    }
    
    return [NSURL URLWithString:[@"http://www.livephish.com" stringByAppendingString:self.relativePagePath]];
}

- (NSString *)displayText {
    if (self.type == LivePhishContainerTypeShow) {
        return self.date;
    }
    else if(self.type == LivePhishContainerTypeAlbum) {
        if(self.album) {
            return self.album;
        }
        else {
            return self.containerInfo;
        }
    }
    
    return [NSString stringWithFormat:@"Unknown Container Type: %d", (int)self.type];
}

- (NSString *)displaySubtext {
    if (self.type == LivePhishContainerTypeShow) {
        return [NSString stringWithFormat:@"%@ — %@", self.artist, self.venue];
    }
    else if(self.type == LivePhishContainerTypeAlbum) {
        return self.artist;
    }
    
    return [NSString stringWithFormat:@"Unknown Container Type: %d", (int)self.type];
}


- (NSString *)displayTextWithDate {
    if (self.type == LivePhishContainerTypeShow) {
        return [NSString stringWithFormat:@"%@ — %@", self.date, self.venue];
    }
    else if(self.type == LivePhishContainerTypeAlbum) {
        if(self.album) {
            return self.album;
        }
        else {
            return self.containerInfo;
        }
    }
    
    return [NSString stringWithFormat:@"Unknown Container Type: %d", (int)self.type];
}

@end
