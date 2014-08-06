//
//  PhishinPlaylistGroup.m
//  PhishOD
//
//  Created by Alec Gorge on 8/6/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinPlaylistGroup.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation PhishinPlaylistStub

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.name = dict[@"name"];
        self.phishinSlug = dict[@"key"];
        self.phishnetAuthor = dict[@"phishnet_author"];
        self.phishinAuthor = dict[@"phishin_author"];
    }
    
    return self;
}

@end

@implementation PhishinPlaylistGroup

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = dict[@"name"];
        self.playlistStubs = [dict[@"playlists_keys"] map:^id(NSDictionary *object) {
            return [PhishinPlaylistStub.alloc initWithDictionary:object];
        }];
    }
    
    return self;
}

@end
