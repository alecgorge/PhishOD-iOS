//
//  IGSourceCell.h
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IGAPIClient.h"

@interface IGSourceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *uiDetailsLabel;

- (void)updateCellWithSource:(IGShow *)source
                 inTableView:(UITableView *)tableView;

@end
