//
//  IGVenue.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <JSONModel.h>

#import "IGShow.h"

@protocol IGShow
@end

@interface IGVenue : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber<Optional> *showCount;
@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSArray<Optional, IGShow> *shows;

@end
