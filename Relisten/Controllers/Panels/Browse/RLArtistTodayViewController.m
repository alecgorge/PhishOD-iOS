//
//  RLArtistTodayViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 1/16/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import "RLArtistTodayViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "IGAPIClient.h"
#import "RLShowSourcesViewController.h"

@interface RLArtistTodayViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic) NSArray<IGTodayArtist *> *today;

@property (nonatomic) NSString *targetedArtistName;

@end

@implementation RLArtistTodayViewController

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.targetedArtistName = nil;
    }
    
    return self;
}

- (instancetype)initWithArtistName:(NSString *)artistName {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.targetedArtistName = artistName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Today in History";
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 66.0f;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = UIView.new;
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
}

- (void)refresh:(id)sender {
    [IGAPIClient.sharedInstance today:^(NSArray<IGTodayArtist *> *s) {
        if(self.targetedArtistName) {
            self.today = [s select:^BOOL(IGTodayArtist *object) {
                return [object.name isEqualToString:self.targetedArtistName];
            }];
        }
        else {
            self.today = s;
        }
        
        [self.tableView reloadData];
        [super refresh:sender];
    }];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.today.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.today[section].shows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.today[section].name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    IGTodayShow *show = self.today[indexPath.section].shows[indexPath.row];
    cell.textLabel.text = show.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    IGTodayShow *show = self.today[indexPath.section].shows[indexPath.row];
    
    if(self.showSelectionCallback) {
        self.showSelectionCallback(show);
        return;
    }
    
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:show.display_date];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

#pragma mark - Empty dataset

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No Shows :(";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"Unfortunately, %@ has not played any shows on this day in history.", self.targetedArtistName];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -50;
}

@end
