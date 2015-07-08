//
//  RLVenuesViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/7/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLVenuesViewController.h"

#import "IGAPIClient.h"
#import "RLShowCollectionViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

@interface RLVenuesViewController ()

@property (nonatomic) NSArray *venues;

@end

@implementation RLVenuesViewController

- (instancetype)init {
    if (self = [super init]) {
        self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Venues"
                                                      image:[UIImage imageNamed:@"glyphicons-27-road"]
                                                        tag:0];
        
        self.navigationController.tabBarItem = self.tabBarItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Venues";
}

- (void)refresh:(id)sender {
   [IGAPIClient.sharedInstance venues:^(NSArray *venues) {
       self.venues = [venues sortedArrayUsingComparator:^NSComparisonResult(IGVenue *obj1, IGVenue *obj2) {
           return [obj1.name compare:obj2.name];
       }];
       
       [self.tableView reloadData];
       [super refresh:sender];
   }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:@"cell"];
    }
    
    IGVenue *ven = self.venues[indexPath.row];
    
    cell.textLabel.text = ven.name;
    cell.detailTextLabel.text = ven.city;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    RLShowCollectionViewController *vc = [RLShowCollectionViewController.alloc initWithVenue:self.venues[indexPath.row]];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f * 1.2f;
}

@end
