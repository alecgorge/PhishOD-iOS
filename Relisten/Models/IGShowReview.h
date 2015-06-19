//
//  IGShowReview.h
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <JSONModel.h>

@protocol IGShowReview
@end

@interface IGShowReview : JSONModel

@property (nonatomic, strong) NSString *reviewbody;
@property (nonatomic, strong) NSString *reviewtitle;
@property (nonatomic, strong) NSString *reviewer;
@property (nonatomic, strong) NSString *reviewdate;
@property (nonatomic, strong) NSNumber<Optional> *stars;

@end
