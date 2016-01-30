//
//  IGSourceCell.m
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "IGSourceCell.h"

#import <AXRatingView/AXRatingView.h>

#import "PHODTrackCell.h"
#import "IGDurationHelper.h"

@interface IGSourceCell ()

@property (weak, nonatomic) IBOutlet UILabel *uiVenueLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiSoundboardLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiDurationLabel;
@property (weak, nonatomic) IBOutlet AXRatingView *uiRatingView;
@property (weak, nonatomic) IBOutlet UILabel *uiRatingReviewCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *uiSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiLineageLabel;
@property (weak, nonatomic) IBOutlet UILabel *uiTaperLabel;

@end

@implementation IGSourceCell

- (void)awakeFromNib {
    self.uiSoundboardLabel.backgroundColor = COLOR_PHISH_GREEN;
    self.uiSoundboardLabel.layer.cornerRadius = 5.0f;
}

- (NSAttributedString *)boldPrefix:(NSString *)pre
                        withSuffix:(NSString *)suf {
    NSMutableAttributedString *a = [NSMutableAttributedString.alloc initWithString:[pre stringByAppendingString:@": "]
                                                                        attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f]}];
    
    [a appendAttributedString:[NSMutableAttributedString.alloc initWithString:suf
                                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}]];
    
    return a;
}

- (void)updateCellWithSource:(IGShow *)show
                 inTableView:(UITableView *)tableView {
    if(show) {
        NSMutableAttributedString *att = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@"%@\n\n%@", show.venue.name, show.venue.city]];
        
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:6.0f],
                             }
                     range:NSMakeRange(show.venue.name.length + 1, 1)];
        
        [att addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                             NSForegroundColorAttributeName: UIColor.darkGrayColor,
                             }
                     range:NSMakeRange(show.venue.name.length + 2, show.venue.city.length)];
        
        self.uiVenueLabel.attributedText = att;
        self.uiDurationLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration];
        self.uiSoundboardLabel.hidden = !show.isSoundboard;
        CGSize s = [self.uiVenueLabel sizeThatFits:CGSizeMake(self.uiVenueLabel.bounds.size.width, CGFLOAT_MAX)];
        
        CGRect r = self.uiVenueLabel.frame;
        r.size = s;
        self.uiVenueLabel.frame = r;
        
        [self.uiDownloadAllButton setImage:[UIImage ipMaskedImageNamed:@"ios-cloud-download-outline"
                                                                 color:COLOR_PHISH_GREEN]
                                  forState:UIControlStateNormal];

        self.uiRatingReviewCountLabel.text = [NSString stringWithFormat:@"%@ reviews", @(show.reviews.count)];
        
        self.uiRatingView.userInteractionEnabled = NO;
        self.uiRatingView.numberOfStar = 5;
        self.uiRatingView.value = show.averageRating;
        
        [self.uiRatingView sizeToFit];
        
        self.uiTaperLabel.attributedText = [self boldPrefix:@"Taper"
                                                 withSuffix:show.taper && ![show.taper isEqualToString:@""] ? show.taper : @"Unknown"];
        self.uiSourceLabel.attributedText = [self boldPrefix:@"Source"
                                                  withSuffix:show.source && ![show.source isEqualToString:@""] ? show.source : @"Unknown"];
        self.uiLineageLabel.attributedText = [self boldPrefix:@"Lineage"
                                                   withSuffix:show.lineage && ![show.lineage isEqualToString:@""] ? show.lineage : @"Unknown"];
    }
    else {
        self.uiVenueLabel.text = @"Loading show...";
        self.uiDurationLabel.text = @"";
        self.uiSoundboardLabel.hidden = YES;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

@end
