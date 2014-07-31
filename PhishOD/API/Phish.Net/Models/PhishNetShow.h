//
//  PhishNetShow.h
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface PhishNetShow : JSONModel

@property (nonatomic) NSString *id;
@property (nonatomic) NSString *dateString;

@property (nonatomic) NSString *venueName;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *country;

@property (nonatomic, readonly) NSString *venue;

@end
