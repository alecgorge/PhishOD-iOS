//
//  PhishTracksStatsFavoritePopover.m
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "PhishTracksStatsFavoritePopover.h"

#import "StreamingMusicViewController.h"
#import "PhishinStreamingPlaylistItem.h"

#import "PhishTracksStats.h"
#import "PhishTracksStatsFavorite.h"

@implementation PhishTracksStatsFavoritePopover

+ (instancetype) sharedInstance {
	static dispatch_once_t once;
    static PhishTracksStatsFavoritePopover *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] init];
	});
    return sharedFoo;
}

- (void)showFromBarButtonItem:(UIView *)item
                       inView:(UIView *)view{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add Track to Favorites", @"Add Show to Favorites", @"Add Tour to Favorites", @"Add Venue to Favorites", nil];
    
    if(IS_IPAD()) {
        if([item isKindOfClass:[UIBarButtonItem class]]) {
            [actionSheet showFromBarButtonItem:(UIBarButtonItem*)item
                                      animated:YES];
        }
        else {
            [actionSheet showFromRect:item.frame
                               inView:view
                             animated:YES];
        }
    }
    else {
        [actionSheet showInView:view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 4) return;
    
    PhishinStreamingPlaylistItem *curr = (PhishinStreamingPlaylistItem *) StreamingMusicViewController.sharedInstance.currentItem;
    
    __block void (^success)(PhishTracksStatsFavorite *) = ^(PhishTracksStatsFavorite *favorite) {
        NSString *favStr = @"";
        
        if(favorite.favoriteType == kStatsFavoriteShow) {
            favStr = @"show";
        }
        else if(favorite.favoriteType == kStatsFavoriteTour) {
            favStr = @"tour";
        }
        else if(favorite.favoriteType == kStatsFavoriteTrack) {
            favStr = @"track";
        }
        else if(favorite.favoriteType == kStatsFavoriteVenue) {
            favStr = @"venue";
        }
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added %@ to favorites!", favStr]];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [SVProgressHUD dismiss];
        });
    };
    
    __block void (^failure)(PhishTracksStatsError *) = ^(PhishTracksStatsError *error) {
        [FailureHandler showAlertWithStatsError:error];
    };
    
    PhishTracksStatsFavorite *fav;
    
    if (buttonIndex == 0) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:curr.track];
    }
    else if (buttonIndex == 1) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:curr.track.show];
    }
    else if (buttonIndex == 2) {
        __block PhishinTour *tour = [[PhishinTour alloc] initWithDictionary:@{ @"id": [NSNumber numberWithInt:curr.track.show.tour_id] }];
        [[PhishinAPI sharedAPI] fullTour:tour
                                 success:^(PhishinTour *newTour) {
                                     tour = newTour;
                                     PhishTracksStatsFavorite *fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:tour];
                                     [[PhishTracksStats sharedInstance] createUserFavoriteTour:[PhishTracksStats sharedInstance].userId
                                                                                      favorite:fav
                                                                                       success:success
                                                                                       failure:failure];
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [FailureHandler showErrorAlertWithMessage:error.localizedDescription];
                                 }];
        
        return;
    }
    else if (buttonIndex == 3) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:curr.track.show.venue];
    }
    
    [[PhishTracksStats sharedInstance] createUserFavoriteTrack:[PhishTracksStats sharedInstance].userId
                                                      favorite:fav
                                                       success:success
                                                       failure:failure];
    
}

@end
