//
//  PhishinEra.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinEra.h"

@implementation PhishinEra

- (instancetype)initWithName:(NSString *)name
					andYears:(NSArray *)years {
	if (self = [super init]) {
		self.name = name;
		self.years = years;
	}
	return self;
}

@end
