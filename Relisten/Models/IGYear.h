//
//  IGYear.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "IGShow.h"

@interface IGYear : JSONModel

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger showCount;
@property (nonatomic, assign) NSInteger recordingCount;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval avgDuration;
@property (nonatomic, assign) double avgRating;

@property (nonatomic, strong) NSArray<Optional, IGShow> *shows;

@end
