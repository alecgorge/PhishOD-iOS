//
//  LongStringTableViewCell.h
//  PhishOD
//
//  Created by Alec Gorge on 8/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongStringTableViewCell : UITableViewCell

@property (nonatomic) UINavigationController *navigationController;

- (void)updateCellWithString:(NSString *)s
                     andFont:(UIFont *)font;
- (void)updateCellWithHTML:(NSString *)s;
- (void)updateCellWithAttributedString:(NSAttributedString *)a;

- (CGFloat)heightForCellWithString:(NSString *)s
                           andFont:(UIFont *)font
                       inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellWithHTML:(NSString *)s
                     inTableView:(UITableView *)tableView;

- (CGFloat)heightForCellWithAttributedString:(NSAttributedString *)a
                                 inTableView:(UITableView *)tableView;

@end
