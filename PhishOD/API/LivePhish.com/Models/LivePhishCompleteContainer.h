//
//  LivePhishCompleteContainer.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "LivePhishContainer.h"

#import "LivePhishSong.h"
#import "LivePhishReview.h"
#import "LivePhishNote.h"
#import "LivePhishAccessList.h"

@interface LivePhishSet : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *songs;

@end

@interface LivePhishCompleteContainer : LivePhishContainer

@property (nonatomic) NSTimeInterval runningTime;

@property (nonatomic) NSArray<LivePhishSong> *songs;
@property (nonatomic) NSArray<Ignore> *sets;

@property (nonatomic) NSArray<LivePhishNote> *notes;
@property (nonatomic) NSArray<LivePhishReview> *reviews;
@property (nonatomic) NSArray<LivePhishAccessList, Optional> *accessList;

@property (nonatomic, readonly) BOOL canStream;
@property (nonatomic, readonly) BOOL hasVideo;
@property (nonatomic) NSURL<Optional> *videoURL;
@property (nonatomic) NSString<Optional> *videoTitle;

@end
