//
//  LivePhishSong.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "PhishinTrack.h"

@class LivePhishCompleteContainer;

@protocol LivePhishSong
@end

@interface LivePhishSong : JSONModel <PHODGenericTrack>

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *title;
@property (nonatomic) NSInteger disc;
@property (nonatomic) NSInteger track;
@property (nonatomic) NSInteger set;
@property (nonatomic) NSURL *clipURL;
@property (nonatomic) NSInteger songId;
@property (nonatomic) NSTimeInterval runningTime;

@property (nonatomic) LivePhishCompleteContainer<Ignore> *container;

@property (nonatomic, readonly) NSInteger trackId;

@end
