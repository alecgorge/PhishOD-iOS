//
//  PlaylistViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 8/6/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "RefreshableTableViewController.h"

@interface PlaylistViewController : RefreshableTableViewController

- (instancetype)initWithPlaylistStub:(PhishinPlaylistStub *)stub;

@property (nonatomic) PhishinPlaylistStub *stub;
@property (nonatomic) PhishinPlaylist *playlist;

@end
