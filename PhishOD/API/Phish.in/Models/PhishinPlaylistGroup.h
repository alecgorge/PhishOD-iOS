//
//  PhishinPlaylistGroup.h
//  PhishOD
//
//  Created by Alec Gorge on 8/6/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishinPlaylistStub : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phishinSlug;
@property (nonatomic) NSString *phishnetAuthor;
@property (nonatomic) NSString *phishinAuthor;

@end

@interface PhishinPlaylistGroup : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *playlistStubs;

@end
