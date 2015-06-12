//
//  PHODTableHeaderView.m
//  PhishOD
//
//  Created by Alec Gorge on 6/9/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODTableHeaderView.h"

@interface PHODTableHeaderView ()

@end

@implementation PHODTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
					 andTitle:(NSString *)title {
	if (self = [super initWithFrame:frame]) {
		[self setupView];
		self.titleLabel.text = title;
		
		self.buttonWidth = 50.0f;
		self.padding = 15.0f;
	}
	return self;
}

- (void)setupView {
	self.titleLabel = [UILabel.alloc initWithFrame:CGRectInset(self.bounds, self.padding, 0)];
	
	UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
	descriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
	
	self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
	self.titleLabel.textColor = UIColor.darkGrayColor;
	
	self.backgroundColor = UIColor.whiteColor;
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	[self addSubview:self.titleLabel];
	[self setNeedsLayout];
}

- (void)addTarget:(id)target
		   action:(SEL)selector {
	if(!self.moreButton) {
		self.moreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		
		[self.moreButton setTitle:@"more"
						 forState:UIControlStateNormal];
		
		self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		
		[self setNeedsLayout];
		[self addSubview:self.moreButton];
	}
	
	[self.moreButton addTarget:target
						action:selector
			  forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
	self.titleLabel.frame = CGRectInset(self.bounds, self.padding, 0);
	self.moreButton.frame = CGRectMake(self.bounds.size.width - self.padding - self.buttonWidth,
									   0,
									   self.buttonWidth,
									   self.bounds.size.height);
}

@end
