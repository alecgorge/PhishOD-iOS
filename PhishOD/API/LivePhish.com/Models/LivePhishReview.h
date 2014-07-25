//
//  LivePhishReview.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@protocol LivePhishReview
@end

@interface LivePhishReview : JSONModel

@property (nonatomic) NSString *author;
@property (nonatomic) NSString *postedDateTimeString;
@property (nonatomic) NSString *review;

@end
