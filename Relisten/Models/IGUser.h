//
//  IGUser.h
//  iguana
//
//  Created by Alec Gorge on 11/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface IGUser : JSONModel

@property (nonatomic) NSInteger id;

@property (nonatomic) NSString *username;

@end
