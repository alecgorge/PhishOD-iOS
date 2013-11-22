//
//  FailureHandler.h
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FailureHandler : NSObject

+(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) returnCallback:(UITableView *)table;

+ (void)showAlertWithStatsError:(NSDictionary *)statsErrorDict;
+ (void)showErrorAlertWithMessage:(NSString *)message;

@end
