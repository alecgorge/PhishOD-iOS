//
//  ShowCell.m
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "ShowCell.h"

#import "IGDurationHelper.h"

@interface ShowCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiSoundboardLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiRemasteredLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiDescriptionLabel;

@property (nonatomic) BOOL shiftRemasteredLabelLeft;

@end

@implementation ShowCell

- (void)awakeFromNib {
    self.uiSoundboardLabel.backgroundColor = COLOR_PHISH_GREEN;
	self.uiRemasteredLabel.backgroundColor = COLOR_PHISH_GREEN;
	
	self.uiRemasteredLabel.layer.cornerRadius =
	self.uiSoundboardLabel.layer.cornerRadius = 5.0f;
	
	CGRect f = self.uiRemasteredLabel.frame;
	if(self.shiftRemasteredLabelLeft) {
		f.origin.x = self.uiSoundboardLabel.frame.origin.x;
	}
	else {
		f.origin.x = self.uiSoundboardLabel.frame.origin.x + self.uiSoundboardLabel.frame.size.width + 4;
	}
	
	self.uiRemasteredLabel.frame = f;
}

- (void)updateCellWithShow:(PhishinShow *)show
			   inTableView:(UITableView *)tableView {
	self.uiDateLabel.text = show.date;
	self.uiDurationLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration / 1000.0f];
	self.uiSoundboardLabel.hidden = !show.sbd;
	self.uiRemasteredLabel.hidden = !show.remastered;
	self.uiDescriptionLabel.text = [show.venue_name stringByAppendingFormat:@" — %@", show.location];
	
	self.shiftRemasteredLabelLeft = show.remastered && !show.sbd;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (CGFloat)heightForCellWithShow:(PhishinShow *)show
					 inTableView:(UITableView *)tableView {
    CGFloat leftMargin = 10;
    CGFloat rightMargin = 50;
    
    CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin, MAXFLOAT);
	
	NSString *showDisText = [show.venue_name stringByAppendingFormat:@" — %@", show.location];
    CGRect labelSize = [showDisText boundingRectWithSize:constraintSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]}
                                                 context:nil];
    
    return MAX(tableView.rowHeight, labelSize.size.height + 35 + 10);
}

@end
