//
//  PhishSong.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishSong : NSObject

// {"id":8488,"title":"My Sweet One","position":1,"duration":159269,"file_url":"/system/tracks/song_files/000/008/488/original/c7607f9ae936bce40f576e10cf5c988dc1d8589b.mp3?1350775372","slug":"my-sweet-one"}

- (id)initWithDictionary:(NSDictionary *)dict;

@property BOOL isPlayable;
@property NSInteger trackId;
@property NSString *title;
@property NSInteger position;
@property NSTimeInterval duration;
@property NSURL *fileURL;
@property NSString *filePath;
@property NSString *slug;

@property NSString *showDate;
@property NSString *showLocation;

@property NSArray *tracks;

@end
