//
//  RLFavoritesManager.m
//  PhishOD
//
//  Created by Alec Gorge on 7/16/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODFavoritesManager.h"

#import <SDCloudUserDefaults/SDCloudUserDefaults.h>

#import "IGAPIClient.h"

static NSString *PHODFavoritesChangedNotificationName = @"PHODFavoritesChangedNotificationName";

#define SDCloudUserDefaults_cloudDefaults NSUserDefaults.standardUserDefaults

@implementation PHODFavoritesManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id inst = nil;
    dispatch_once(&onceToken, ^{
        inst = PHODFavoritesManager.new;
    });
    
    return inst;
}

- (void)raiseNotification {
    [NSNotificationCenter.defaultCenter postNotificationName:PHODFavoritesChangedNotificationName
                                                      object:self];
}

- (NSString *)artistKey {
#ifdef IS_PHISH
    NSString *key = @"phish";
#else
    NSString *key = IGAPIClient.sharedInstance.artist.slug;
#endif
    return key;
}

- (NSArray *)favorites {
    NSDictionary *artists = [SDCloudUserDefaults objectForKey:@"favorites"];
    
    if (!artists) {
        [SDCloudUserDefaults setObject:@[]
                                forKey:@"favorites"];
        
        return [SDCloudUserDefaults objectForKey:@"favorites"];
    }
    
    if (![artists isKindOfClass:NSMutableDictionary.class]) {
        artists = NSMutableDictionary.dictionary;
    }

    NSString *key = self.artistKey;
    NSArray *art = artists[key];
    
    if(!art) {
        NSMutableDictionary *mutArtists = artists.mutableCopy;
        mutArtists[key] = art = @[];
        [SDCloudUserDefaults setObject:mutArtists
                                forKey:@"favorites"];
    }
    
    return art;
}

- (BOOL)showDateIsAFavorite:(NSString *)showDate {
    return [self.favorites containsObject:showDate];
}

- (void)addFavoriteShowDate:(NSString *)showDate {
    NSMutableArray *artistFavs = self.favorites.mutableCopy;
    NSMutableDictionary *artists = [[SDCloudUserDefaults objectForKey:@"favorites"] mutableCopy];
    
    if (![artists isKindOfClass:NSMutableDictionary.class]) {
        artists = NSMutableDictionary.dictionary;
    }
    
    [artistFavs addObject:showDate];
    artists[self.artistKey] = artistFavs;

    [SDCloudUserDefaults setObject:artists
                            forKey:@"favorites"];
    
    [SDCloudUserDefaults synchronize];
    
    [self raiseNotification];
}

- (void)removeFavoriteShowDate:(NSString *)showDate {
    NSMutableArray *artistFavs = self.favorites.mutableCopy;
    NSMutableDictionary *artists = [[SDCloudUserDefaults objectForKey:@"favorites"] mutableCopy];
    
    [artistFavs removeObject:showDate];
    artists[self.artistKey] = artistFavs;
    
    [SDCloudUserDefaults setObject:artists
                            forKey:@"favorites"];
    
    [SDCloudUserDefaults synchronize];
    
    [self raiseNotification];
}

@end
