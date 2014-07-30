//
//  PhishNetBlogItem.h
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface PhishNetBlogItem : JSONModel

@property (nonatomic) NSString *id;
@property (nonatomic) NSString *author;
@property (nonatomic) NSString *title;
@property (nonatomic) NSURL *URL;

@property (nonatomic) NSString *dateString;

@property (nonatomic, readonly) NSDate *date;

@end
