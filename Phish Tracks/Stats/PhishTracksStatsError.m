//
//  PhishTracksStatsError.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/22/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishTracksStatsError.h"

#define STATS_ERROR_DOMAIN @"PhishTracks Stats"

@implementation PhishTracksStatsError

+ (PhishTracksStatsError *)errorWithStatsErrorDictionary:(NSDictionary *)errorDict httpStatus:(NSInteger)httpStatus
{
	return [[PhishTracksStatsError alloc] initWithStatsErrorCode:[errorDict[@"error_code"] integerValue]
														 message:errorDict[@"message"]
												validationErrors:errorDict[@"errors"]
													  httpStatus:httpStatus];
}

+ (PhishTracksStatsError *)errorWithError:(NSError *)error
{
	return [PhishTracksStatsError errorWithDomain:STATS_ERROR_DOMAIN code:error.code userInfo:error.userInfo];
}

- (id)initWithStatsErrorCode:(NSInteger)errorCode message:(NSString *)message validationErrors:(NSArray *)validationErrors httpStatus:(NSInteger)httpStatus
{
//	NSMutableDictionary *userInfoDict = [@{ NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"%@ (err# %ld)", message, (long)errorCode],
//											NSLocalizedDescriptionKey: message,
//											@"HttpStatus": [NSNumber numberWithInteger:httpStatus] } mutableCopy];
    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
    
    [userInfoDict setObject:[NSNumber numberWithInteger:httpStatus] forKey:@"HttpStatus"];
    
    if (errorCode > 0 && message) {
        [userInfoDict setObject:[NSString stringWithFormat:@"%@ (err# %ld)", message, (long)errorCode] forKey:NSLocalizedFailureReasonErrorKey];
        [userInfoDict setObject:message forKey:NSLocalizedDescriptionKey];
    }
    else if (message) {
        [userInfoDict setObject:message forKey:NSLocalizedDescriptionKey];
    }
    else {
        [userInfoDict setObject:@"An error occurred." forKey:NSLocalizedDescriptionKey];
    }

	if (validationErrors && validationErrors.count > 0) {
		[userInfoDict setValue:[validationErrors objectAtIndex:0] forKey:NSLocalizedRecoverySuggestionErrorKey];
	}

	if (self = [super initWithDomain:STATS_ERROR_DOMAIN code:errorCode userInfo:userInfoDict]) {
		self.apiErrorCode = errorCode;
		self.apiErrorMessage = message;
		self.apiValidationErrors = validationErrors;
	}

	return self;
}

- (NSInteger)httpStatus
{
	return [self.userInfo[@"HttpStatus"] integerValue];
}

- (NSString *)primaryErrorMessage
{
	if ([self localizedRecoverySuggestion]) {
		return [self localizedRecoverySuggestion];
	}

	return [self localizedDescription];
}

@end
