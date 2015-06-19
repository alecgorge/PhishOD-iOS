//
//  IGAPIClient.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGAPIClient.h"

#import "AppDelegate.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

#define IGUANA_API_URL_BASE @"http://relisten.net/api"

@interface IGAPIClient ()

@property (nonatomic, strong) IGYear *year;

@end

@implementation IGAPIClient

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:IGUANA_API_URL_BASE]];
    });
    return sharedInstance;
}

- (void)failure:(NSError *)error {
    UIViewController *present = AppDelegate.sharedDelegate.window.rootViewController;
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Error"
                                                               message:error.localizedDescription
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Okay"
                                          style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                              [present dismissViewControllerAnimated:YES
                                                                          completion:nil];
                                          }]];
    
   [present presentViewController:a
                         animated:YES
                       completion:nil];
}

- (void)artists:(void (^)(NSArray *))success {
    [self GET:@"artists"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGArtist *a = [[IGArtist alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return a;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

-(void)playlists:(void (^)(NSArray *))success {
    [self GET:@"playlists/all"
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGPlaylist *p = [[IGPlaylist alloc] initWithDictionary:item
                                                           error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return p;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (NSString *)routeForArtist:(NSString *)route {
    return [NSString stringWithFormat:@"artists/%@/%@", self.artist.slug, route];
}

- (void)years:(void (^)(NSArray *))success {
    [self GET:[self routeForArtist:@"years"]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGYear *y = [[IGYear alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)venuesForArtist:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/venues/", self.artist.slug]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGVenue *y = [[IGVenue alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)year:(NSUInteger)year success:(void (^)(IGYear *))success {
    [self GET:[[NSString stringWithFormat:@"artists/%@/years/", self.artist.slug]
               stringByAppendingFormat:@"%lu", (unsigned long)year]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSError *err;
          IGYear *y = [[IGYear alloc] initWithDictionary:responseObject[@"data"]
                                                   error:&err];
          
          if(err) {
              [self failure: err];
              dbug(@"json err: %@", err);
          }
          
          success(y);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)venue:(IGVenue *)venue success:(void (^)(IGVenue *))success {
    [self GET:[[NSString stringWithFormat:@"artists/%@/venues/", self.artist.slug] stringByAppendingFormat:@"%lu", (unsigned long)venue.id]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSError *err;
          IGVenue *y = [[IGVenue alloc] initWithDictionary:responseObject[@"data"]
													 error:&err];
          
          if(err) {
              [self failure: err];
              dbug(@"json err: %@", err);
          }
          
          success(y);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)topShowsForArtist:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/top_shows/", self.artist.slug]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)showsOn:(NSString *)displayDate success:(void (^)(NSArray *))success {
    [self GET:[[NSString stringWithFormat:@"artists/%@/years/", self.artist.slug]
               stringByAppendingFormat:@"%@/shows/%@", [displayDate substringToIndex:4], displayDate]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

- (void)randomShowForArtist:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/random_show/", self.artist.slug]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              else {
                  for(IGTrack *t in y.tracks) {
                      t.show = y;
                  }
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
}

@end
