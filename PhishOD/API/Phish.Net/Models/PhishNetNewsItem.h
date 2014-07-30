//
//  PhishNetNewsItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface PhishNetNewsItem : JSONModel

@property (nonatomic) NSString *id;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *dateString;
@property (nonatomic) NSString *postHTML;

@property (nonatomic, readonly) NSURL<Ignore> *URL;
@property (nonatomic, readonly) NSDate<Ignore> *date;

@end
