//
//  LivePhishAccessList.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@protocol LivePhishAccessList
@end

@interface LivePhishAccessList : JSONModel

@property (nonatomic) NSInteger pass;
@property (nonatomic) NSInteger sku;
@property (nonatomic) BOOL canPlay;

@end
