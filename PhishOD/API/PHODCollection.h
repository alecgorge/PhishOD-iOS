//
//  PHODCollection.h
//  PhishOD
//
//  Created by Alec Gorge on 5/14/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PhishAlbumArtCache.h"

@class MPMediaItemArtwork;

@protocol PHODCollection <FICEntity>

- (MPMediaItemArtwork *)albumArt;
- (NSString *)displayText;
- (NSString *)displaySubtext;

@end
