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

typedef enum {
	kTrackBtn,
	kShowBtn,
	kVenueBtn,
	kTourBtn
} StatsFavContextTrack;

//typedef enum {
//	kShowBtn,
//	kVenueBtn,
//	kTourBtn
//} StatsFavContextShow;
//
//typedef enum {
//	kVenueBtn
//} StatsFavContextVenue;
//
//typedef enum {
//	kTourBtn
//} StatsFavContextTour;

@implementation PhishTracksStatsFavoritePopover {
    NSMutableDictionary *buttonIndecies;
//    id _phishinObject;
    PhishinTrack *_track;
    PhishinShow  *_show;
    int _tour_id;
    PhishinVenue *_venue;
}

-(id)init {
    self = [super init];
    if (self) {
        buttonIndecies = [NSMutableDictionary dictionary];
        buttonIndecies[@"track"]  = [NSNumber numberWithInt:-1];
        buttonIndecies[@"show"]   = [NSNumber numberWithInt:-1];
        buttonIndecies[@"tour"]   = [NSNumber numberWithInt:-1];
        buttonIndecies[@"venue"]  = [NSNumber numberWithInt:-1];
        buttonIndecies[@"cancel"] = [NSNumber numberWithInt:-1];
    }
    return self;
}

+ (instancetype) sharedInstance {
	static dispatch_once_t once;
    static PhishTracksStatsFavoritePopover *sharedFoo;
    dispatch_once(&once, ^ {
		sharedFoo = [[self alloc] init];
	});
    return sharedFoo;
}

- (void)showFromBarButtonItem:(UIView *)item
                       inView:(UIView *)view
            withPhishinObject:(id)phishinObject {
    buttonIndecies[@"track"]  = [NSNumber numberWithInt:-1];
    buttonIndecies[@"show"]   = [NSNumber numberWithInt:-1];
    buttonIndecies[@"tour"]   = [NSNumber numberWithInt:-1];
    buttonIndecies[@"venue"]  = [NSNumber numberWithInt:-1];
    buttonIndecies[@"cancel"] = [NSNumber numberWithInt:-1];
    
    BOOL isTrack = [phishinObject isKindOfClass:[PhishinTrack class]];
    BOOL isShow  = [phishinObject isKindOfClass:[PhishinShow class]];
    BOOL isTour  = [phishinObject isKindOfClass:[PhishinTour class]];
    BOOL isVenue = [phishinObject isKindOfClass:[PhishinVenue class]];
    
    NSString *titleString;
    
    if (isTrack) {
        titleString = @"This menu is for favoriting the currently playing track.";
    }
    else {
        titleString = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleString
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    
    if (isTrack) {
        buttonIndecies[@"track"] = [NSNumber numberWithInteger:[actionSheet addButtonWithTitle:@"Add Track to Favorites"]];
        _track = phishinObject;
        _show = _track.show;
        _venue = _show.venue;
        _tour_id = _show.tour_id;
//        buttonCount++;
    }
    
    if (isShow) {
        _show = phishinObject;
        _venue = _show.venue;
        _tour_id = _show.tour_id;
    }
    
    if (isVenue) {
        _venue = phishinObject;
    }
    
    if (isTour) {
        _tour_id = ((PhishinTour *)phishinObject).id;
    }
    
    if (isTrack || isShow) {
        buttonIndecies[@"show"] = [NSNumber numberWithInteger:[actionSheet addButtonWithTitle:@"Add Show to Favorites"]];
//        buttonCount++;
    }
    
    if (isTrack || isShow || isVenue) {
        buttonIndecies[@"venue"] = [NSNumber numberWithInteger:[actionSheet addButtonWithTitle:@"Add Venue to Favorites"]];
//        buttonCount++;
    }
    
    if (isTrack || isShow || isTour) {
        buttonIndecies[@"tour"] = [NSNumber numberWithInteger:[actionSheet addButtonWithTitle:@"Add Tour to Favorites"]];
//        buttonCount++;
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    buttonIndecies[@"cancel"] = [NSNumber numberWithInteger:actionSheet.cancelButtonIndex];
    
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
    if(buttonIndex == [buttonIndecies[@"cancel"] intValue]) return;
    
//    PhishinStreamingPlaylistItem *curr = (PhishinStreamingPlaylistItem *) StreamingMusicViewController.sharedInstance.currentItem;
    
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
    
    if (buttonIndex == [buttonIndecies[@"track"] intValue]) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:_track];
        [[PhishTracksStats sharedInstance] createUserFavoriteTrack:[PhishTracksStats sharedInstance].userId
                                                          favorite:fav
                                                           success:success
                                                           failure:failure];
    }
    else if (buttonIndex == [buttonIndecies[@"show"] intValue]) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:_show];
        [[PhishTracksStats sharedInstance] createUserFavoriteShow:[PhishTracksStats sharedInstance].userId
                                                         favorite:fav
                                                          success:success
                                                          failure:failure];
    }
    else if (buttonIndex == [buttonIndecies[@"tour"] intValue]) {
        __block PhishinTour *tour = [[PhishinTour alloc] initWithDictionary:@{ @"id": [NSNumber numberWithInt:_tour_id] }];
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
    else if (buttonIndex == [buttonIndecies[@"venue"] intValue]) {
        fav = [[PhishTracksStatsFavorite alloc] initWithPhishinEntity:_venue];
        [[PhishTracksStats sharedInstance] createUserFavoriteVenue:[PhishTracksStats sharedInstance].userId
                                                          favorite:fav
                                                           success:success
                                                           failure:failure];
    }
}

@end
