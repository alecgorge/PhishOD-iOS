//
//  PHODFavortiesViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/16/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "PHODFavortiesViewController.h"

#import "PHODFavoritesManager.h"
#import "ShowViewController.h"
#import "RLShowSourcesViewController.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <CSNNotificationObserver/CSNNotificationObserver.h>

@interface PHODFavortiesViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic) CSNNotificationObserver *notifier;

@end

@implementation PHODFavortiesViewController

- (instancetype)init {
    if (self = [super init]) {
        self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Favorites"
                                                      image:[UIImage imageNamed:@"glyphicons-50-star"]
                                                        tag:0];
        
        self.navigationController.tabBarItem = self.tabBarItem;
        self.navigationItem.title = self.title = @"Favorites";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.tableView.tableFooterView = UIView.new;
    
    self.notifier = [CSNNotificationObserver.alloc initWithName:PHODFavoritesChangedNotificationName
                                                         object:nil
                                                          queue:NSOperationQueue.mainQueue
                                                     usingBlock:^(NSNotification *notification) {
                                                         [self.tableView reloadData];
                                                     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return PHODFavoritesManager.sharedInstance.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = PHODFavoritesManager.sharedInstance.favorites[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    NSString *date = PHODFavoritesManager.sharedInstance.favorites[indexPath.row];;
    
#ifdef IS_PHISH
    ShowViewController *vc = [ShowViewController.alloc initWithShowDate:date];
#else
    RLShowSourcesViewController *vc = [RLShowSourcesViewController.alloc initWithDisplayDate:date];
#endif
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [PHODFavoritesManager.sharedInstance removeFavoriteShowDate:PHODFavoritesManager.sharedInstance.favorites[indexPath.row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Empty Data Set

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No Favorited Shows :(";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [NSAttributedString.alloc initWithString:text
                                         attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"You can favorite any show by tapping the heart outline or by pressing the three dots by the currently playing track. Bonus: your favorites list will automatically sync between all of your devices.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [NSAttributedString.alloc initWithString:text
                                         attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return NO;
}

@end
