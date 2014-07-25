//
//  LivePhishCategory.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface LivePhishCategory : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *relativeImagePath;

@property (nonatomic, readonly) NSURL *imageURL;

@end
