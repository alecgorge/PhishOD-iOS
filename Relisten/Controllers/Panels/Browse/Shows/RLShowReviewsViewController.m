//
//  RLShowReviewsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLShowReviewsViewController.h"

#import <AXRatingView/AXRatingView.h>

#import "IGAPIClient.h"
#import "IGReviewCell.h"

@interface RLShowReviewsViewController ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) IGShow *show;

@end

@implementation RLShowReviewsViewController

- (instancetype)initWithShow:(IGShow *)show {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.show = show;
        
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateStyle = NSDateFormatterShortStyle;
        self.formatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)self.show.reviews.count];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 256.0f;
    self.tableView.separatorColor = UIColor.whiteColor;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGReviewCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"review"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AppDelegate.sharedDelegate.navDelegate addBarToViewController:self];
    [AppDelegate.sharedDelegate.navDelegate fixForViewController:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.show.reviews.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    IGShowReview *review = self.show.reviews[row];
    
    IGReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"review"
                                                         forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell updateCellWithReview:review
                   inTableView:tableView];
    
    return cell;
}

@end
