//
//  PhishinSet.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinSet.h"

@implementation PhishinSet

- (id)initWithTitle:(NSString *)name andTracks:(NSArray *)tracks {
    self = [super init];
    if (self) {
        self.title = name;
		self.tracks = tracks;
    }
    return self;
}

@end
