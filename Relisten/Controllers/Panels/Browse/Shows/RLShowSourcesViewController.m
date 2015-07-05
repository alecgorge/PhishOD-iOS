//
//  RLShowSourcesViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/30/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLShowSourcesViewController.h"

#import "IGDurationHelper.h"
#import "IGSourceCell.h"

#import <AXRatingView/AXRatingView.h>

NS_ENUM(NSInteger, IGSourcesRows) {
    IGSourcesSourceRow,
    IGSourcesSelectRow,
    IGSourcesRowCount,
};

@interface RLShowSourcesViewController ()

@property (nonatomic) NSString *displayDate;

@end

@implementation RLShowSourcesViewController

- (instancetype)initWithDisplayDate:(NSString *)displayDate {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.displayDate = displayDate;
    }
    return self;
}

- (instancetype)initWithRandomDate {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55.0f;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGSourceCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"source"];
    
    [self applyTitle];
}

- (void)applyTitle {
    if(self.displayDate) {
        self.title = [NSString stringWithFormat:@"%@ Sources", self.displayDate];
    }
    else {
        self.title = @"Random Shows";
    }
}

- (void)refresh:(id)sender {
    if(self.displayDate == nil) {
        [IGAPIClient.sharedInstance randomShow:^(NSArray *shows) {
            self.fullShows = shows;
        }];
    }
    else {
        [IGAPIClient.sharedInstance showsOn:self.displayDate
                                    success:^(NSArray *shows) {
                                        self.displayDate = ((IGShow *)shows[0]).displayDate;
                                        self.fullShows = shows;
                                        
                                        [self applyTitle];
                                        
                                        [self.tableView reloadData];
                                        [super refresh:sender];
                                    }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fullShows.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return IGSourcesRowCount;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Source %ld of %lu", (long)section + 1, (unsigned long)self.fullShows.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"source";
    
    if(indexPath.row == IGSourcesAverageRatingRow
       || indexPath.row == IGSourcesDurationRow) {
        CellIdentifier = @"kv";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        if([CellIdentifier isEqualToString:@"source"]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:CellIdentifier];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:CellIdentifier];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSInteger row = indexPath.row;
    IGShow *show = self.fullShows[indexPath.section];
    
    if(row == IGSourcesTaperRow) {
        cell.textLabel.text = @"Taper";
        cell.detailTextLabel.text = show.taper;
    }
    else if(row == IGSourcesSourceRow) {
        cell.textLabel.text = @"Source";
        cell.detailTextLabel.text = show.source;
        cell.detailTextLabel.preferredMaxLayoutWidth = self.tableView.bounds.size.width;
    }
    else if(row == IGSourcesLineageRow) {
        cell.textLabel.text = @"Lineage";
        cell.detailTextLabel.text = show.lineage;
        cell.detailTextLabel.preferredMaxLayoutWidth = self.tableView.bounds.size.width;
    }
    else if(row == IGSourcesAverageRatingRow) {
        cell.textLabel.text = @"Average Rating";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu  ", (unsigned long)show.reviewsCount];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        AXRatingView *rating = [[AXRatingView alloc] initWithFrame:CGRectMake(0, 0, 51, 20)];
        rating.userInteractionEnabled = NO;
        [rating sizeToFit];
        rating.value = show.averageRating;
        
        cell.accessoryView = rating;
    }
    else if(row == IGSourcesDurationRow) {
        cell.textLabel.text = @"Duration";
        cell.detailTextLabel.text = [IGDurationHelper formattedTimeWithInterval:show.duration];
    }
    else if(row == IGSourcesSelectRow) {
        cell.textLabel.text = @"Listen to this source";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"glyphicons-76-headphones"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

@end
