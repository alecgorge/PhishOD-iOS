//
//  FavoriteTracksViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/24/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FavoriteTracksViewController.h"
#import "ShowViewController.h"

@interface FavoriteTracksViewController ()

@end

@implementation FavoriteTracksViewController

- (id)init
{
    self = [super init];
    if (self) {
        sectionIndexTitlesSelector = @selector(trackTitle);
        self.title = @"Tracks";
    }
    return self;
}

- (void)refreshFavorites
{
    [[PhishTracksStats sharedInstance] getAllUserFavoriteTracks:[PhishTracksStats sharedInstance].userId success:^(NSArray *favs) {
        [self buildSectionIndices:favs];
//        NSLog(@"favorites = %@", self.favorites);
//        for (PhishTracksStatsFavorite *f in favs) {
//            NSLog(@"fav=%@", f);
//        }
    } failure:^(PhishTracksStatsError *error) {
        dbug(@"favorite tracks controller err=%@", error);
        [FailureHandler showAlertWithStatsError:error];
    }];
}

- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return favorite.trackTitle;
}

- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return [NSString stringWithFormat:@"%@ - %@ - %@", favorite.showDate, favorite.venueName, favorite.location];
}

- (UITableViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite
{
    ShowViewController *c = [[ShowViewController alloc] initWithShowDate:favorite.showDate];
    c.autoplayTrackId = [favorite.trackId integerValue];
    c.autoplay = YES;
    return c;
}

- (void)deleteActionForFavorite:(PhishTracksStatsFavorite *)favorite
{
    [[PhishTracksStats sharedInstance] destroyUserFavoriteTrack:[PhishTracksStats sharedInstance].userId
                                                     favoriteId:[favorite.favoriteId integerValue]
        success:^{
            [self refreshFavorites];
        }
        failure:^(PhishTracksStatsError *error) {
            dbug(@"favorite tracks controller err=%@", error);
            [FailureHandler showAlertWithStatsError:error];
        }];
}

@end
