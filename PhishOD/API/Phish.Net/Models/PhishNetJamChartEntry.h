//
//  PhishNetJamChartEntry.h
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishNetJamChartEntry : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic) BOOL isKey;
@property (nonatomic) BOOL isNoteworthy;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSTimeInterval length;
@property (nonatomic) NSString *notes;

@end
