//
//  PhishYear.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishYear : NSObject

// [{"created_at":"2012-10-20T23:22:52Z","id":415,"location":"Alumni Hall, Brown University - Providence, RI","remastered":false,"sbd":true,"show_date":"1991-02-01","updated_at":"2012-10-21T00:00:19Z"}, ...]

@property NSString *year;

@property BOOL hasShowsLoaded;
@property NSArray *shows;

- (id) initWithYear:(NSString *)_year;
- (id) initWithYear:(NSString *)year andShowsJSONArray:(NSArray *) arr;

@end
