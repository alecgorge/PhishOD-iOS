//
//  ShowHeaderView.m
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "ShowHeaderView.h"

#import "IGDurationHelper.h"
#import "PHODTrackCell.h"
#import "PhishinShow.h"

@interface ShowHeaderView ()

@property (nonatomic) BOOL shiftSoundboardRight;
- (IBAction)cellTapped:(id)sender;

@end

@implementation ShowHeaderView

- (void)awakeFromNib {
    self.uiSoundboardLabel.backgroundColor = COLOR_PHISH_GREEN;
	self.uiRemasteredLabel.backgroundColor = COLOR_PHISH_GREEN;
	
	self.uiRemasteredLabel.layer.cornerRadius =
	self.uiSoundboardLabel.layer.cornerRadius = 5.0f;
}

- (void)updateCellForShow:(PhishinShow *)show
			  withSetlist:(PhishNetSetlist *)setlist
			  inTableView:(UITableView *)tableView {
	if(show) {
		NSMutableAttributedString *att = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@\n\n%@", show.venue.name, show.venue.location]];
		
		[att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:6.0f],
							 }
					 range:NSMakeRange(show.venue.name.length + 1, 1)];
		
		[att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
							 NSForegroundColorAttributeName: UIColor.darkGrayColor,
							 }
					 range:NSMakeRange(show.venue.name.length + 2, show.venue.location.length)];
		
		self.uiVenueLabel.attributedText = att;
		self.uiDurationLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration / 1000.0f];
		self.uiSoundboardLabel.hidden = !show.sbd;
		self.uiRemasteredLabel.hidden = !show.remastered;
		CGSize s = [self.uiVenueLabel sizeThatFits:CGSizeMake(self.uiVenueLabel.bounds.size.width, CGFLOAT_MAX)];
		
		CGRect r = self.uiVenueLabel.frame;
		r.size = s;
		self.uiVenueLabel.frame = r;
		
		self.shiftSoundboardRight = !show.remastered && show.sbd;
		
		CGRect f = self.uiSoundboardLabel.frame;
		if(self.shiftSoundboardRight) {
			f.origin.x = self.bounds.size.width - 15 - f.size.width;
		}
		else {
			f.origin.x = self.bounds.size.width - 15 - self.uiRemasteredLabel.frame.size.width - 4 - self.uiSoundboardLabel.frame.size.width;
		}
		
		self.uiSoundboardLabel.frame = f;
        
        [self.uiDownloadAllButton setImage:[UIImage ipMaskedImageNamed:@"ios-cloud-download-outline"
                                                                 color:COLOR_PHISH_GREEN]
                                  forState:UIControlStateNormal];
	}
	else {
		self.uiVenueLabel.text = @"Loading show...";
		self.uiDurationLabel.text = @"";
		self.uiSoundboardLabel.hidden =
		self.uiRemasteredLabel.hidden = YES;
	}
	
	if(setlist) {
		self.uiRatingReviewCountLabel.text = [NSString stringWithFormat:@"%@ ratings —  %@ reviews", setlist.ratingCount, @(setlist.reviews.count)];
		
		self.uiRatingView.userInteractionEnabled = NO;
		self.uiRatingView.numberOfStar = 5;
		self.uiRatingView.value = setlist.rating.floatValue;
		
		[self.uiRatingView sizeToFit];
		
		CGRect f = self.uiRatingView.frame;
		f.origin.x = self.bounds.size.width - f.size.width - 15.0f;
		self.uiRatingView.frame = f;
	}
	else {
		self.uiRatingReviewCountLabel.text = @"Loading reviews...";
	}
}

+ (CGFloat)cellHeightForShow:(PhishinShow *)show
				 inTableView:(UITableView *)tableView {
	return 120.0f;
}

- (IBAction)uiDownloadAllTapped:(id)sender {
    if(self.downloadAllTapped) {
        self.downloadAllTapped();
    }
}

- (IBAction)cellTapped:(id)sender {
	if(self.headerTapped) {
		self.headerTapped();
	}
}
@end
