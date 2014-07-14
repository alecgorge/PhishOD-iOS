//
//  PhishShow.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishShow : NSObject

// {"created_at":"2012-10-20T23:22:52Z","id":415,"location":"Alumni Hall, Brown University - Providence, RI","remastered":false,"sbd":true,"show_date":"1991-02-01","updated_at":"2012-10-21T00:00:19Z"}

@property NSInteger showId;
@property NSString *location;
@property NSString *city;
@property (getter = isRemastered) BOOL remastered;
@property (getter = isSoundboard) BOOL soundboard;
@property NSString *showDate;

@property BOOL hasSetsLoaded;
@property NSArray *sets;

- (id)initWithDictionary:(NSDictionary *) dict;

@end
