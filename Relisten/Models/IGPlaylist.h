//
//  IGPlaylist.h
//  iguana
//
//  Created by Manik Kalra on 11/30/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "IGTrack.h"

@interface IGPlaylist : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger id;

@property (nonatomic) NSArray<Optional, IGTrack> *tracks;

@end
