//
//  FavoriteShowsViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/26/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FavoriteShowsViewController.h"
#import "ShowViewController.h"

@interface FavoriteShowsViewController ()

@end

@implementation FavoriteShowsViewController

- (id)init
{
    self = [super init];
    if (self) {
        sectionIndexTitlesSelector = @selector(showDate);
        self.title = @"Shows";
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
    [[PhishTracksStats sharedInstance] getAllUserFavoriteShows:[PhishTracksStats sharedInstance].userId success:^(NSArray *favs) {
        [self buildSectionIndices:favs];
    } failure:^(PhishTracksStatsError *error) {
        CLS_LOG(@"favorite shows controller err=%@", error);
        [FailureHandler showAlertWithStatsError:error];
    }];
}

- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return favorite.showDate;
}

- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return [NSString stringWithFormat:@"%@ - %@", favorite.venueName, favorite.location];
}

- (UITableViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite
{
    ShowViewController *c = [[ShowViewController alloc] initWithShowDate:favorite.showDate];
    return c;
}

- (void)deleteActionForFavorite:(PhishTracksStatsFavorite *)favorite
{
    [[PhishTracksStats sharedInstance] destroyUserFavoriteShow:[PhishTracksStats sharedInstance].userId
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
