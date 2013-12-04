//
//  FailureHandler.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhishTracksStatsError.h"

@interface FailureHandler : NSObject

+(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) returnCallback:(UITableView *)table;

+ (void)showAlertWithStatsError:(PhishTracksStatsError *)statsError;
+ (void)showErrorAlertWithMessage:(NSString *)message;

@end
