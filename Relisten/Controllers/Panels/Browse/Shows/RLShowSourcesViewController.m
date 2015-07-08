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
#import "RLShowViewController.h"

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
        self.displayDate = nil;
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
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
    
    [self applyTitle];
}

- (void)applyTitle {
    if(self.displayDate) {
        self.title = [NSString stringWithFormat:@"%@ Sources", self.displayDate];
    }
    else {
        self.title = @"Random Show";
    }
}

- (void)refresh:(id)sender {
    if(self.displayDate == nil) {
        [IGAPIClient.sharedInstance randomShow:^(NSArray *shows) {
            self.fullShows = shows;
            IGShow *firstShow = shows[0];
            self.displayDate = firstShow.displayDate;
            
            [self.tableView reloadData];
            [super refresh:sender];
            [self applyTitle];
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
    UITableViewCell *cell = nil;
    IGShow *show = self.fullShows[indexPath.section];
    
    if(indexPath.row == IGSourcesSourceRow) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"source"
                                               forIndexPath:indexPath];
        IGSourceCell *c = (IGSourceCell *)cell;
        
        [c updateCellWithSource:show
                    inTableView:tableView];
    }
    else if(indexPath.row == IGSourcesSelectRow) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                               forIndexPath:indexPath];
        
        cell.imageView.image = [UIImage imageNamed:@"glyphicons_076_headphones"];
        cell.backgroundColor = COLOR_PHISH_GREEN;
        cell.textLabel.textColor = COLOR_PHISH_WHITE;
        cell.textLabel.text = @"Listen to this source";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.row == IGSourcesSelectRow) {
        RLShowViewController *vc = [RLShowViewController.alloc initWithShow:self.fullShows[indexPath.section]];
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

@end
