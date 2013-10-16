//
//  PhishinTrack.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhishinShow;

@interface PhishinTrack : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict andShow:(PhishinShow*)show;

@property (nonatomic, assign) int id;
@property (nonatomic) NSString *title;
@property (nonatomic, assign) int position;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic) NSString *set;
@property (nonatomic, assign) int likes_count;
@property (nonatomic) NSString *show_date;
@property (nonatomic, assign) int show_id;
@property (nonatomic) NSString *slug;
@property (nonatomic) NSURL *mp3;
@property (nonatomic) NSArray *song_ids;

@property (nonatomic) BOOL isBold;

@property (nonatomic) PhishinShow *show;

- (NSString*)shareURLWithPlayedTime:(NSTimeInterval)elapsed;

@end
