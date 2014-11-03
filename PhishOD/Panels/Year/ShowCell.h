//
//  ShowCell.h
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowCell : UITableViewCell

- (void)updateCellWithShow:(PhishinShow *)show
                inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellWithShow:(PhishinShow *)show
                      inTableView:(UITableView *)tableView;

- (void)updateHeatmapLabelWithValue:(float)val;

@end
