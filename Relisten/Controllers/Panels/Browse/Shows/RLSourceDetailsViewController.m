//
//  RLSourceDetailsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 1/28/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import "RLSourceDetailsViewController.h"

#import "IGAPIClient.h"
#import "RLShowViewController.h"
#import "RLShowReviewsViewController.h"
#import "LongStringViewController.h"
#import "RLShowCollectionViewController.h"

#import <SVWebViewController/SVWebViewController.h>

typedef NS_ENUM(NSInteger, RLSourceDetailRows) {
    RLSourceDetailVenueRow,
    RLSourceDetailRatingRow,
    RLSourceDetailReviewsRow,
    RLSourceDetailTaperNotesRow,
    RLSourceDetailViewOriginalRow,
    RLSourceDetailRowCount,
};

@interface RLSourceDetailsViewController ()

@property (nonatomic) RLShowViewController *showVc;

@end

@implementation RLSourceDetailsViewController

- (instancetype)initWithShowViewController:(RLShowViewController *)showVc {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.showVc = showVc;
        self.title = @"Details";
    }
    
    return self;
}

- (IGShow *)show {
    return self.showVc.show;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return RLSourceDetailRowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == RLSourceDetailRatingRow) {
        static NSString *CellIdentifier = @"RatingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Rating";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/5.00 (%@ ratings)", @(self.show.averageRating), @(self.show.reviews.count)];
        
        return cell;
    }
    else if(indexPath.row == RLSourceDetailVenueRow) {
        static NSString *CellIdentifier = @"RatingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Venue";
        cell.detailTextLabel.text = self.show.venue.name;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if(indexPath.row == RLSourceDetailReviewsRow) {
        static NSString *CellIdentifier = @"InfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)self.show.reviews.count];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if(indexPath.row == RLSourceDetailTaperNotesRow) {
        static NSString *CellIdentifier = @"InfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Taper Notes";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if(indexPath.row == RLSourceDetailViewOriginalRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
        
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"InfoCell"];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"View on %@", self.show.origSource];
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if(indexPath.row == RLSourceDetailReviewsRow) {
        RLShowReviewsViewController *vc = [RLShowReviewsViewController.alloc initWithShow:self.show];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    if(indexPath.row == RLSourceDetailViewOriginalRow) {
        SVWebViewController *vc = [SVWebViewController.alloc initWithAddress:self.show.origSourceLink];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    if(indexPath.row == RLSourceDetailTaperNotesRow) {
        LongStringViewController *vc = [LongStringViewController.alloc initWithString:self.show.showDescription];
        vc.title = @"Taper Notes";
        vc.monospace = YES;
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
    else if(indexPath.row == RLSourceDetailVenueRow) {
        RLShowCollectionViewController *vc = [RLShowCollectionViewController.alloc initWithVenue:self.show.venue];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

@end
