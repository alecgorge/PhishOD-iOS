//
//  PhishinEra.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishinYear.h"

@interface PhishinEra : NSObject

- (instancetype)initWithName:(NSString*)name andYears:(NSArray*)years;

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *years;

@end
