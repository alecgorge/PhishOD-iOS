//
//  IGArtists.h
//  iguana
//
//  Created by Manik Kalra on 10/14/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface IGArtist : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger recordingCount;
@property (nonatomic, strong) NSString<Optional> *musicbrainzId;

@end
