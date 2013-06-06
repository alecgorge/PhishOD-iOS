//
//  FailureHandler.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FailureHandler.h"

@implementation FailureHandler

+ (void (^)(AFHTTPRequestOperation *, NSError *))returnCallback:(UITableView *)table {
	return ^(AFHTTPRequestOperation *op, NSError *err) {
		UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error!"
													message:[err localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
		[a show];
		[table.pullToRefreshView stopAnimating];
	};
}

@end
