//
//  LivePhishBrowseViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishBrowseViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "LivePhishAPI.h"
#import "LivePhishCategoryViewController.h"
#import "LargeImageTableViewCell.h"

@interface LivePhishBrowseViewController ()

@property (nonatomic) NSArray *categories;

@end

@implementation LivePhishBrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Browse LivePhish";
    
    [self.tableView registerClass:LargeImageTableViewCell.class
           forCellReuseIdentifier:@"cell"];
}

- (void)refresh:(id)sender {
	[LivePhishAPI.sharedInstance categories:^(NSArray *categories) {
        self.categories = categories;
        
        [self.tableView reloadData];
        [super refresh:sender];
    }
                                    failure:REQUEST_FAILED(self.tableView)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(!self.categories) {
        return 0;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UIImage *)placeholderImage {
    static UIImage *img;
    
    if(img == nil) {
        CGSize size = CGSizeMake(88.0f, 88.0f);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    LivePhishCategory *cat = self.categories[indexPath.row];
    
    cell.textLabel.text = cat.name.capitalizedString;
    cell.textLabel.numberOfLines = 3;
    
    [cell.imageView sd_setImageWithURL:cat.imageURL
                      placeholderImage:self.placeholderImage];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    LivePhishCategory *cat = self.categories[indexPath.row];
    LivePhishCategoryViewController *vc = [LivePhishCategoryViewController.alloc initWithCategory:cat];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
