//
//  FavoriteVenuesViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/26/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "FavoriteVenuesViewController.h"
#import "VenueViewController.h"

@interface FavoriteVenuesViewController ()

@end

@implementation FavoriteVenuesViewController

- (id)init
{
    self = [super init];
    if (self) {
        sectionIndexTitlesSelector = @selector(venueName);
        self.title = @"Venues";
    }
    return self;
}

- (void)refreshFavorites
{
    [[PhishTracksStats sharedInstance] getAllUserFavoriteVenues:[PhishTracksStats sharedInstance].userId success:^(NSArray *favs) {
        [self buildSectionIndices:favs];
    } failure:^(PhishTracksStatsError *error) {
        dbug(@"favorite venues controller err=%@", error);
        [FailureHandler showAlertWithStatsError:error];
    }];
}

- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return favorite.venueName;
}

- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
    return [NSString stringWithFormat:@"%@ - %@ shows", favorite.location, favorite.venueShowsCount];
}

- (UIViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite
{
    PhishinVenue *venue = [[PhishinVenue alloc] initWithDictionary:@{ @"id": favorite.venueId,
                                                                      @"name": favorite.venueName,
                                                                      @"past_names": favorite.venuePastNames,
                                                                      @"latitude": favorite.venueLatitude,
                                                                      @"longitude": favorite.venueLongitude,
                                                                      @"shows_count": favorite.venueShowsCount,
                                                                      @"slug": favorite.venueSlug,
                                                                      @"location": favorite.location }];
    VenueViewController *c = [[VenueViewController alloc] initWithVenue:venue];
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
