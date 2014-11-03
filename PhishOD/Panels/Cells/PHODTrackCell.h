//
//  PHODTrackCell.h
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHODTrackCell : UITableViewCell

- (void)updateCellWithTrack:(NSObject<PHODGenericTrack> *)track
                inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellWithTrack:(NSObject<PHODGenericTrack> *)track
                      inTableView:(UITableView *)tableView;

- (void)updateHeatmapLabelWithValue:(float)val;
@end
