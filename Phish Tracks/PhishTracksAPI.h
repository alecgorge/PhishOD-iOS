//
//  PhishTracksAPI.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "AFHTTPClient.h"
#import "PhishYear.h"
#import "PhishShow.h"
#import "PhishSet.h"
#import "PhishSong.h"

@interface PhishTracksAPI : AFHTTPClient

+(PhishTracksAPI*)sharedAPI;

-(void)years:(void ( ^ ) ( NSArray *phishYears ))success failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)fullYear:(PhishYear *)year success:(void ( ^ ) ( PhishYear * ))success failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;
-(void)fullShow:(PhishShow *)show success:(void ( ^ ) ( PhishShow * ))success failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;
-(void)fullSong:(PhishSong *)song success:(void ( ^ ) ( PhishSong * ))success failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

-(void)songs:(void ( ^ ) ( NSArray *phishSongs ))success failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

@end
