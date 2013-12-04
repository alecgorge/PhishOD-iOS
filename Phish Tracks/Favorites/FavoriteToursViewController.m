//
//  FavoriteToursViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/26/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FavoriteToursViewController.h"
#import "TourViewController.h"

@interface FavoriteToursViewController ()

@end

@implementation FavoriteToursViewController

- (id)init
{
    self = [super init];
    if (self) {
        sectionIndexTitlesSelector = @selector(tourStartsOn);
        self.title = @"Tours";
    }
    return self;
}

- (NSString *)sectionIndexTitleForString:(NSString *)string
{
    NSString *firstLetters = [string substringToIndex:4];
    return firstLetters;
}

- (void)refreshFavorites
{
    [[PhishTracksStats sharedInstance] getAllUserFavoriteTours:[PhishTracksStats sharedInstance].userId success:^(NSArray *favs) {
        [self buildSectionIndices:favs];
    } failure:^(PhishTracksStatsError *error) {
        CLS_LOG(@"favorite shows controller err=%@", error);
        [FailureHandler showAlertWithStatsError:error];
    }];
}

- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return favorite.tourName;
}

- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return [NSString stringWithFormat:@"%@ to %@ - %@ shows", favorite.tourStartsOn, favorite.tourEndsOn, favorite.tourShowsCount];
}

- (UITableViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite
{
    PhishinTour *tour = [[PhishinTour alloc] initWithDictionary:@{ @"id": favorite.tourId }];
    TourViewController *c = [[TourViewController alloc] initWithTour:tour];
    return c;
}

- (void)deleteActionForFavorite:(PhishTracksStatsFavorite *)favorite
{
    [[PhishTracksStats sharedInstance] destroyUserFavoriteTour:[PhishTracksStats sharedInstance].userId
                                                     favoriteId:[favorite.favoriteId integerValue]
        success:^{
            [self refreshFavorites];
        }
        failure:^(PhishTracksStatsError *error) {
            CLS_LOG(@"favorite tracks controller err=%@", error);
            [FailureHandler showAlertWithStatsError:error];
        }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionTitles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.sectionTitles map:^NSString *(NSString *secTitle){
        return [secTitle substringFromIndex:2];
    }];
}


@end
