//
//  BadgeAndHeatmapCell.h
//  PhishOD
//
//  Created by Alexander Bird on 10/18/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "TDBadgedCell.h"

@interface BadgeAndHeatmapCell : TDBadgedCell

- (void)updateHeatmapLabelWithValue:(float)val;

@end
