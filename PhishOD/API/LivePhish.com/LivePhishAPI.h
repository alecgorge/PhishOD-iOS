//
//  LivePhishAPI.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "AFHTTPClient.h"

#import "LivePhishCategory.h"
#import "LivePhishContainer.h"
#import "LivePhishCompleteContainer.h"
#import "LivePhishStash.h"

@interface LivePhishAPI : AFHTTPClient

+(instancetype)sharedInstance;

- (void)categories:(void ( ^ ) ( NSArray *categories ))success
           failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)featuredContainers:(void ( ^ ) ( NSArray *categories ))success
				   failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)containersForCategory:(LivePhishCategory *)cat
                      success:(void ( ^ ) ( NSArray *containers ))success
                      failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)completeContainerForContainer:(LivePhishContainer *)cont
                              success:(void ( ^ ) ( LivePhishCompleteContainer *container ))success
                              failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)getUserTokenForUsername:(NSString *)username
                   withPassword:(NSString *)password
                        success:(void ( ^ ) ( BOOL validCredentials, NSString *token ))success
                        failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)userStash:(void(^)(LivePhishStash *stash))success
          failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)userCompleteContainerForContainer:(LivePhishContainer *)cont
                                  success:(void(^)(LivePhishCompleteContainer *stash))success
                                  failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

- (void)streamURLForSong:(LivePhishSong *)song
   withCompleteContainer:(LivePhishCompleteContainer *)completeContainer
                 success:(void(^)(NSURL *streamURL))success
                 failure:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error ))failure;

@end
