//
//  PhishinSet.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishinSet : NSObject

- (instancetype)initWithTitle:(NSString *)name andTracks:(NSArray*)tracks;

@property (nonatomic) NSString *title;
@property (nonatomic) NSArray *tracks;

@end
