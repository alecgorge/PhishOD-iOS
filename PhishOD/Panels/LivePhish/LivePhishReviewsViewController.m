//
//  LivePhishReviewsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishReviewsViewController.h"

#import "LivePhishAPI.h"

typedef NS_ENUM(NSInteger, LivePhishReviewRows) {
    LivePhishReviewAuthorRow,
    LivePhishReviewReviewRow,
    LivePhishReviewRowCount,
};

@interface LivePhishReviewsViewController ()

@property (nonatomic) LivePhishCompleteContainer *container;

@end

@implementation LivePhishReviewsViewController

- (instancetype)initWithCompleteContainer:(LivePhishCompleteContainer *)container {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.container = container;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Reviews";
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.container.reviews.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return LivePhishReviewRowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LivePhishReview *review = self.container.reviews[indexPath.section];
    
    if (indexPath.row != LivePhishReviewReviewRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"value1"];
        
        if(!cell) {
            cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:@"value1"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if(indexPath.row == LivePhishReviewAuthorRow) {
            cell.textLabel.text = review.author;
            cell.detailTextLabel.text = review.postedDateTimeString;
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = review.review;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != LivePhishReviewReviewRow) {
        return UITableViewAutomaticDimension;
    }
    
    LivePhishReview *review = self.container.reviews[indexPath.section];
    
    CGRect r = [review.review boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 30, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]}
                                           context:nil];
    
    return MAX(tableView.rowHeight, r.size.height + 24);
}

@end
