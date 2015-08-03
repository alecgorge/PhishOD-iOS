//
//  RLFavoritesManager.h
//  PhishOD
//
//  Created by Alec Gorge on 7/16/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *PHODFavoritesChangedNotificationName;

@interface PHODFavoritesManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSArray *favorites;

- (BOOL)showDateIsAFavorite:(NSString *)showDate;
- (void)addFavoriteShowDate:(NSString *)showDate;
- (void)removeFavoriteShowDate:(NSString *)showDate;

@end
