//
//  LivePhishStash.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

#import "LivePhishContainer.h"

@interface LivePhishStash : JSONModel

@property (nonatomic) NSArray<LivePhishContainer> *passes;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSString *email;

@end
