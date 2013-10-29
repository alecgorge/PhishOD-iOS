//
//  MenuPanel.h
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishinStreamingPlaylistItem.h"

@interface MenuPanel : UITableViewController

- (void)updateNowPlayingWithStreamingPlaylistItem:(StreamingPlaylistItem*)item;

@property StreamingPlaylistItem *item;

@end
