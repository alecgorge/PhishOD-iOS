//
//  PhishTracksStatsError.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStatsError : NSError

+ (PhishTracksStatsError *)errorWithStatsErrorDictionary:(NSDictionary *)errorDict httpStatus:(NSInteger)httpStatus;
+ (PhishTracksStatsError *)errorWithError:(NSError *)error;

@property NSInteger apiErrorCode;
@property NSString *apiErrorMessage;
@property NSArray *apiValidationErrors;
@property(readonly) NSInteger httpStatus;

- (NSString *)primaryErrorMessage;

@end
