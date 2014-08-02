//
//  PhishinPlaylist.h
//  PhishOD
//
//  Created by Alec Gorge on 8/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishinPlaylist : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic) NSString *slug;
@property (nonatomic) NSString *name;

@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) NSArray *tracks;

@property (nonatomic, readonly) NSURL *shareURL;

@end
