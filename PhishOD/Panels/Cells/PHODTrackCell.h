//
//  PHODTrackCell.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhishinTrack.h"

@interface UIImage (IPImageUtils)

+ (UIImage *)ipMaskedImageNamed:(NSString *)name color:(UIColor *)color;

@end

@interface PHODTrackCell : UITableViewCell


- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView;

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
             AndTrackNumber:(NSInteger)number
                inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView;

- (void)updateHeatmapLabelWithValue:(float)val;
- (void)showHeatmap:(BOOL)show;

- (NSObject<PHODGenericTrack> *)getTrack;

@end
