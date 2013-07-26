//
//  PhishTracksStats.h
//  Phish Tracks
//
//  Created by Alec Gorge on 7/23/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhishTracksStats : NSObject

+ (PhishTracksStats*)sharedInstance;

- (void)testUsername:(NSString *)username
			password:(NSString *)password
			callback:(BOOL(^)(void))cb;

@end
