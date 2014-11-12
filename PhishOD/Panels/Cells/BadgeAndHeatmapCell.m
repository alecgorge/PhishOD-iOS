//
//  BadgeAndHeatmapCell.m
//  PhishOD
//
//  Created by Alexander Bird on 10/18/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "BadgeAndHeatmapCell.h"
//#import "PhishOD-Prefix.pch"

//@interface BadgeAndHeatmapCell : ()
//
//@property (weak, nonatomic) IBOutlet UIView *heatmapView;
//@property (weak, nonatomic) IBOutlet UIView *heatmapValue;
//
//@end

@implementation BadgeAndHeatmapCell {
	UIView *_heatmapView;
	UIView *_heatmapValue;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		[self configureHeatmap];
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		[self configureHeatmap];
	}
	return self;
}

- (void)configureHeatmap
{
	if (!_heatmapView) {
		CGFloat h = 36, w = 4;
		_heatmapValue = [[UIView alloc] initWithFrame:CGRectMake(0, 20, w, h)];
		_heatmapValue.backgroundColor = COLOR_PHISH_GREEN;
		_heatmapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
		_heatmapView.clipsToBounds = YES;
		_heatmapView.backgroundColor = COLOR_PHISH_LIGHT_GREEN;
		[_heatmapView addSubview:_heatmapValue];
	}
	
	[self.contentView addSubview:_heatmapView];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat h = self.frame.size.height;
	CGFloat w = self.frame.size.width;
	CGFloat hm_h    = _heatmapView.frame.size.height;
	CGFloat hm_x    = w - 38.0;
	CGFloat hm_y    = h - hm_h - (h - hm_h)/2.0;
	
	_heatmapView.frame = CGRectMake(hm_x, hm_y, 4, hm_h);
}

- (void)updateHeatmapLabelWithValue:(float)val {
	_heatmapView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"heatmaps.enabled"];
	CGFloat max_height = _heatmapView.frame.size.height;
	CGRect hm = _heatmapValue.frame;
	hm.origin.y = max_height * (1 - val);
	_heatmapValue.frame = hm;
}

@end
