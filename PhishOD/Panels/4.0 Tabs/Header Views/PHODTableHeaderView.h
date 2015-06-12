//
//  PHODTableHeaderView.h
//  PhishOD
//
//  Created by Alec Gorge on 6/9/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHODTableHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame
					 andTitle:(NSString *)title;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *moreButton;

@property (nonatomic) CGFloat buttonWidth;
@property (nonatomic) CGFloat padding;

- (void)addTarget:(id)target
		   action:(SEL)selector;

@end
