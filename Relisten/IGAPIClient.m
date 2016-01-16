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
#import <FCFileManager/FCFileManager.h>

#define IGUANA_API_URL_BASE @"http://iguana.app.alecgorge.com/api"

@implementation IGDownloadItem

+ (NSString *)provider {
    return @"relisten.net";
}

+ (id)showForPath:(NSString *)path {
    return [IGShow loadShowFromCacheForShowId:path.lastPathComponent.integerValue];
}

- (instancetype)initWithTrack:(IGTrack *)track
                      andShow:(IGShow *)show {
    if (self = [super init]) {
        _track = track;
        _show = show;
    }
    return self;
}

- (NSString *)cachePath {
    return [NSString stringWithFormat:@"%@/%ld/%@.mp3", IGAPIClient.sharedInstance.artist.slug, self.show.id, @(self.track.id).stringValue];
}

- (NSString *)provider {
    return [IGDownloadItem provider];
}

- (NSInteger)id {
    return self.track.id;
}

- (void)downloadURL:(void (^)(NSURL *))dl {
    dl(self.track.mp3);
}

- (void)cache {
    [self.show cache];
}

+ (void)showsWithCachedTracks:(void (^)(NSArray *))success {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
        NSString *path = [[self cacheDir] stringByAppendingPathComponent:[self provider]];
        
        dbug(@"searching %@", [path stringByAppendingPathComponent:IGAPIClient.sharedInstance.artist.slug]);
        
        NSArray *arr = [FCFileManager listItemsInDirectoryAtPath:[path stringByAppendingPathComponent:IGAPIClient.sharedInstance.artist.slug]
                                                            deep:NO];
        
        arr = [arr map:^id(NSString *path) {
            return [self showForPath:path];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            success(arr);
        });
    });
}

@end

@implementation IGDownloader

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static IGDownloader *sharedFoo;
    dispatch_once(&once, ^ {
        sharedFoo = [self.alloc init];
    });
    return sharedFoo;
}

-(PHODDownloadOperation *)downloadTrack:(IGTrack *)track
                                 inShow:(IGShow *)show
                               progress:(void (^)(int64_t totalBytes, int64_t completedBytes))progress
                                success:(void (^)(NSURL *fileURL)) success
                                failure:(void ( ^ ) ( NSError *error ))failure {
    return [self downloadItem:[IGDownloadItem.alloc initWithTrack:track
                                                          andShow:show]
                     progress:progress
                      success:success
                      failure:failure];
}

@end

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

- (void)search:(NSString *)queryString success:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/search", self.artist.slug]
   parameters:@{@"q": queryString}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          IGArtist *currentArtist = [self.artist copy];
          NSArray *s = [responseObject[@"data"][@"shows"] map:^id(id item) {
              NSError *err;
              IGShow *s = [[IGShow alloc] initWithDictionary:item error:&err];
              s.artist = currentArtist;
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return s;
          }];
          
//          NSArray *t = [responseObject[@"data"][@"tracks"] map:^id(id item) {
//              NSLog(@"%@", item);
//              NSError *err;
//              IGTrack *t = [[IGTrack alloc] initWithDictionary:item error:&err];
//              
//              if(err) {
//                  [self failure: err];
//                  dbug(@"json err: %@", err);
//              }
//              
//              return t;
//          }];
          
          NSArray *v = [responseObject[@"data"][@"venues"] map:^id(id item) {
              NSError *err;
              IGVenue *v = [[IGVenue alloc] initWithDictionary:item error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return v;
          }];
          
//          success([NSArray arrayWithObjects: s, t, v, nil]);
          success([NSArray arrayWithObjects: s, v, nil]);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          [self failure:error];
          
          success(nil);
      }];
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

- (void)venues:(void (^)(NSArray *))success {
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

- (void)topShows:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/top_shows/", self.artist.slug]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          IGArtist *currentArtist = [self.artist copy];
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              y.artist = currentArtist;
              
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
          IGArtist *currentArtist = [self.artist copy];
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              
              y.artist = currentArtist;
              
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

- (void)randomShow:(void (^)(NSArray *))success {
    [self GET:[NSString stringWithFormat:@"artists/%@/random_show/", self.artist.slug]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          IGArtist *currentArtist = [self.artist copy];
          NSArray *r = [responseObject[@"data"] map:^id(id item) {
              NSError *err;
              IGShow *y = [[IGShow alloc] initWithDictionary:item
                                                       error:&err];
              y.artist = currentArtist;
              
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

- (void)playTrack:(IGTrack *)track
           inShow:(IGShow *)show {    
    AFHTTPSessionManager *ssss = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
    ssss.requestSerializer = [AFJSONRequestSerializer serializer];
    ssss.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [ssss POST:@"play"
    parameters:@{@"song":@{@"title": track.title,
                           @"slug": track.slug,
                           @"band": show.artist.slug,
                           @"year": [NSString stringWithFormat:@"%ld", (long)show.year],
                           @"month": [show.displayDate substringWithRange:NSMakeRange(5, 2)],
                           @"day": [show.displayDate substringWithRange:NSMakeRange(8, 2)],
                           @"showVersion": @"0",
                           @"id": [NSString stringWithFormat:@"%ld", (long)track.id],
                           @"bandName": show.artist.name
                           }}
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
           
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           
       }];
}

- (void)today:(void (^)(NSArray<IGTodayArtist *> *))success {
    [self GET:@"today"
   parameters:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
          NSArray *r = [responseObject[@"tih"] map:^id(id object) {
              NSError *err;
              IGTodayArtist *y = [[IGTodayArtist alloc] initWithDictionary:object
                                                                     error:&err];
              
              if(err) {
                  [self failure: err];
                  dbug(@"json err: %@", err);
              }
              
              return y;
          }];
          
          success(r);
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          [self failure:error];
          success(nil);
      }];
}

@end
