//
//  BaseFavoritableEntityViewController.h
//  Phish Tracks
//
//  Created by Alexander Bird on 11/24/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishTracksStatsFavorite.h"
#import "PhishTracksStats.h"

@interface BaseFavoritableEntityViewController : UITableViewController {
    UIBarButtonItem *editButtonItem;
//    NSMutableArray *favorites;
    SEL sectionIndexTitlesSelector;
}

@property NSMutableDictionary *sections;
@property NSArray *sectionTitles;

- (void)refreshFavorites;
- (void)buildSectionIndices:(NSArray *)favorites;
- (NSString *)sectionIndexTitleForString:(NSString *)string;
- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite;
- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite;
- (UIViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite;
- (void)deleteActionForFavorite:(PhishTracksStatsFavorite *)favorite;

@end
