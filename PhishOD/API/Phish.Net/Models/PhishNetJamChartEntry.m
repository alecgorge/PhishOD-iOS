//
//  PhishNetJamChartEntry.m
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetJamChartEntry.h"

@implementation PhishNetJamChartEntry

- (instancetype)initWithDictionary:(NSDictionary *)dict {
	if (self = [super init]) {
		self.isKey = [dict[@"isKey"] boolValue];
		self.isNoteworthy = [dict[@"isNoteworthy"] boolValue];
		self.date = dict[@"date"];
		self.length = [dict[@"length"] floatValue];
		self.notes = dict[@"notes"];
	}
	return self;
}

@end
