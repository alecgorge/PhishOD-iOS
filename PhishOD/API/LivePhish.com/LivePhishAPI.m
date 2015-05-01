//
//  LivePhishAPI.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishAPI.h"

#import "LivePhishAuth.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <StreamingKit/STKHTTPDataSource.h>

@implementation LivePhishAPI

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static LivePhishAPI *inst;
    dispatch_once(&once, ^ {
		inst = [self.alloc initWithBaseURL:[NSURL URLWithString: @"https://www.livephish.com"]];
        
		[inst.requestSerializer setValue:@"application/json"
					  forHTTPHeaderField:@"Accept"];
        
		[inst.requestSerializer setValue:@"LivePhishApp"
					  forHTTPHeaderField:@"User-Agent"];
		
		[STKHTTPDataSource setDefaultUserAgent:@"LivePhishApp"];
	});
    return inst;
}

- (id)parseJSON:(id)data {
	return data;
}

- (void)getUserTokenForUsername:(NSString *)username
                   withPassword:(NSString *)password
                        success:(void (^)(BOOL, NSString *))success
                        failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    NSDictionary *dict = @{@"user": username ? username : @"", @"pw": password ? password : @""};
    
    [self secureApiMethod:@"session.getUserToken"
                   params:dict
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSDictionary *dict = [self parseJSON:responseObject][@"Response"];
                      
                      if([dict[@"returnCode"] boolValue]) {
                          if (!dict[@"tokenValue"]) {
                              [self secureApiMethod:@"session.getUserToken"
                                             params:dict
                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                NSDictionary *dict = [self parseJSON:responseObject][@"Response"];
                                                
                                                if([dict[@"returnCode"] boolValue]) {
                                                    success(YES, dict[@"tokenValue"]);
                                                }
                                                else {
                                                    success(NO, nil);
                                                }
                                                
                                            }
                                              error:failure];
                          }
                          else {
                              success(YES, dict[@"tokenValue"]);
                          }
                      }
                      else {
                          success(NO, nil);
                      }
                  }
                    error:failure];
}

- (void)apiMethod:(NSString *)apiMethod
           params:(NSDictionary *)dict
          success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
            error:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) error {
    NSMutableDictionary *params = @{@"method": apiMethod}.mutableCopy;
    
    if(dict != nil) {
        [params addEntriesFromDictionary:dict];
    }
    
    [self GET:@"/api.aspx"
   parameters:params
	  success:success
	  failure:error];
}

- (void)secureApiMethod:(NSString *)apiMethod
                 params:(NSDictionary *)dict
                success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                  error:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) error {
    NSMutableDictionary *params = @{@"method": apiMethod,
                                    @"developerKey": @"sjeurd87ehhdjxy6syaj625",
                                    @"clientID": @"Yuejd764ydxcnh4676scsr345",
                                    @"user": LivePhishAuth.sharedInstance.hasCredentials ? LivePhishAuth.sharedInstance.username : @""
                                    }.mutableCopy;
    
    if(dict != nil) {
        [params addEntriesFromDictionary:dict];
    }
    
    [self GET:@"/secureApi.aspx"
   parameters:params
	  success:success
	  failure:error];
}

- (NSError *)livePhishAuthError {
    return [NSError.alloc initWithDomain:@"com.alecgorge.Phish-Tracks"
                                    code:48232
                                userInfo:@{NSLocalizedDescriptionKey: @"Your LivePhish email or password is incorrect. Try again or edit your username and password from the settings screen available from the main menu."}];
}

- (void)tokenProtectedApiMethod:(NSString *)apiMethod
                         params:(NSDictionary *)dict
                        success:(void ( ^ ) ( AFHTTPRequestOperation *operation , id responseObject )) success
                          error:(void ( ^ ) ( AFHTTPRequestOperation *operation , NSError *error )) error {
    [self getUserTokenForUsername:LivePhishAuth.sharedInstance.username
                     withPassword:LivePhishAuth.sharedInstance.password
                          success:^(BOOL validCredentials, NSString *token) {
                              if(!validCredentials || !token) {
                                  error(nil, [self livePhishAuthError]);
                              }
                              
                              NSMutableDictionary *parms = @{@"token": token}.mutableCopy;
                              
                              if(dict != nil) {
                                  [parms addEntriesFromDictionary:dict];
                              }
                              
                              [self secureApiMethod:apiMethod
                                             params:parms
                                            success:success
                                              error:error];
                          }
                          failure:error];
}

- (void)categories:(void (^)(NSArray *))success
           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self apiMethod:@"catalog.containerCategories"
             params:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containerCategories"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishCategory.alloc initWithDictionary:object
                                                                   error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
            }
              error:failure];
}

- (void)featuredContainers:(void (^)(NSArray *))success
				   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
	[self apiMethod:@"catalog.featuredMerchandised"
			 params:nil
			success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containers"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishContainer.alloc initWithDictionary:object
                                                                    error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
			}
			  error:failure];
}

- (void)containersForCategory:(LivePhishCategory *)cat
                      success:(void (^)(NSArray *))success
                      failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [self apiMethod:@"catalog.containerCategories.containers"
             params:@{@"containerCategoryID": @(cat.id)}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containers"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishContainer.alloc initWithDictionary:object
                                                                    error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
            }
              error:failure];
}

- (void)completeContainerForContainer:(LivePhishContainer *)cont
                              success:(void (^)(LivePhishCompleteContainer *))success
                              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self userCompleteContainerForContainer:cont
                                    success:success
                                    failure:failure];
    /*
	 [self apiMethod:@"catalog.container"
	 params:@{@"containerID": @(cont.id)}
	 success:^(AFHTTPRequestOperation *operation, id responseObject) {
	 NSError *err;
	 
	 id object = [self parseJSON:responseObject][@"Response"];
	 id obj = [LivePhishCompleteContainer.alloc initWithDictionary:object
	 error:&err];
	 
	 if(err) {
	 dbug(@"JSON Validation Error on %@: %@", object, err);
	 }
	 
	 success(obj);
	 }
	 error:failure];
     */
}

- (void)userStash:(void (^)(LivePhishStash *))success
          failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self tokenProtectedApiMethod:@"user.stash"
                           params:nil
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSError *err;
                              
                              id object = [self parseJSON:responseObject];
                              id obj = [LivePhishStash.alloc initWithDictionary:object[@"Response"]
                                                                          error:&err];
                              
                              if(err) {
                                  dbug(@"JSON Validation Error on %@: %@", object, err);
                              }
                              
                              success(obj);
                          }
                            error:failure];
}

- (void)userCompleteContainerForContainer:(LivePhishContainer *)cont
                                  success:(void (^)(LivePhishCompleteContainer *))success
                                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self tokenProtectedApiMethod:@"user.catalog.container"
                           params:@{@"containerID": @(cont.id)}
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSError *err;
                              
                              id object = [self parseJSON:responseObject][@"Response"];
                              LivePhishCompleteContainer *obj = [LivePhishCompleteContainer.alloc initWithDictionary:object
                                                                                                               error:&err];
                              
                              if(err) {
                                  dbug(@"JSON Validation Error on %@: %@", object, err);
                              }
                              else {
                                  [obj.songs each:^(LivePhishSong *song) {
                                      song.container = obj;
                                  }];
                              }
                              
                              success(obj);
                          }
                            error:failure];
}

- (void)streamURLForSong:(LivePhishSong *)song
   withCompleteContainer:(LivePhishCompleteContainer *)completeContainer
                 success:(void (^)(NSURL *))success
                 failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    if(completeContainer.accessList.count < 1) {
        failure(nil, [NSError.alloc initWithDomain:@"com.alecgorge.Phish-Tracks"
                                              code:151
                                          userInfo:@{NSLocalizedDescriptionKey: @"You don't have access to this track!"}]);
        return;
    }
    
    LivePhishAccessList *accessList = completeContainer.accessList[0];
    
    [self tokenProtectedApiMethod:@"user.player"
                           params:@{@"trackID": @(song.trackId),
                                    @"passID": @(accessList.pass),
                                    @"skuID": @(accessList.sku)}
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSDictionary *dict = [self parseJSON:responseObject];
                              
                              success([NSURL URLWithString:dict[@"Response"][@"url"]]);
                          }
                            error:failure];
}

- (void)years:(void (^)(NSArray *))success
      failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self apiMethod:@"catalog.showYearCatalog"
             params:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dict = [self parseJSON:responseObject];
                
                success(dict[@"response"]);
            }
              error:failure];
}

- (void)albums:(void (^)(NSArray *))success
       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure{
    [self apiMethod:@"catalog.containersAll"
             params:@{@"cnType": @"albums",
                      @"limit": @"20000",
                      @"sortType": @"asc",
                      @"startOffset":@"0"}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containers"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishContainer.alloc initWithDictionary:object
                                                                    error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
            }
              error:failure];
}

- (void)tours:(void (^)(NSArray *))success
      failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self apiMethod:@"catalog.containerCategories"
             params:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containerCategories"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishCategory.alloc initWithDictionary:object
                                                                   error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
            }
              error:failure];
}

- (void)containersForYear:(NSString *)year
                  success:(void (^)(NSArray *))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [self apiMethod:@"catalog.containersAll"
             params:@{@"limit": @"20000",
                      @"showYears": year,
                      @"sortType": @"asc",
                      @"startOffset":@"0"}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                success([[self parseJSON:responseObject][@"Response"][@"containers"] map:^id(NSDictionary *object) {
                    NSError *err;
                    
                    id obj = [LivePhishContainer.alloc initWithDictionary:object
                                                                    error:&err];
                    
                    if(err) {
                        dbug(@"JSON Validation Error on %@: %@", object, err);
                    }
                    
                    return obj;
                }]);
            }
              error:failure];
}

@end
