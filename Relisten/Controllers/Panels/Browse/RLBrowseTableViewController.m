//
//  RLBrowseTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLBrowseTableViewController.h"

#import "IGAPIClient.h"
#import "IGYearCell.h"
#import "RLShowCollectionViewController.h"
#import "RLShowSourcesViewController.h"
#import "RLHistoryViewController.h"
#import "RLArtistTabViewController.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, RLBrowseSections) {
	RLBrowseRandomShowSection,
	RLBrowseYearSection,
	RLBrowseSectionsCount
};

@interface RLBrowseTableViewController ()

@property (nonatomic) NSArray *years;

@end

@implementation RLBrowseTableViewController

- (instancetype)init {
	if (self = [super init]) {
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Browse"
													  image:[UIImage imageNamed:@"glyphicons-58-history"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
        self.navigationItem.title = self.title = IGAPIClient.sharedInstance.artist.name;
        
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGYearCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"year"];
	
	[self.tableView registerClass:UITableViewCell.class
		   forCellReuseIdentifier:@"cell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55.0f;
    
    UIBarButtonItem *closeBtn = [UIBarButtonItem.alloc initWithTitle:@"All Artists"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(close)];
    
    self.navigationItem.rightBarButtonItem = closeBtn;
}

- (void)close {
    [AppDelegate.sharedDelegate.tabs dismissViewControllerAnimated:YES
                                                        completion:nil];
}

- (void)refresh:(id)sender {
	[IGAPIClient.sharedInstance years:^(NSArray *years) {
		self.years = years;
		
		[self.tableView reloadData];
		[super refresh:sender];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.years ? RLBrowseSectionsCount : 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == RLBrowseRandomShowSection) {
		return 2;
	}
	else if(section == RLBrowseYearSection) {
		return self.years ? self.years.count : 0;
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if (section == RLBrowseYearSection) {
		return [NSString stringWithFormat:@"%ld years", self.years.count];
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == RLBrowseRandomShowSection) {
        if(indexPath.row == 0) {
            return 88.0f;
        }
	}
	else if(indexPath.section == RLBrowseYearSection) {
		return IGYearCell.height;
	}
	
	return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	if(indexPath.section == RLBrowseRandomShowSection) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
											   forIndexPath:indexPath];
		
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Random Show";
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = @"Recently Played Shows";
        }
        
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if(indexPath.section == RLBrowseYearSection) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"year"
											   forIndexPath:indexPath];
		
		IGYearCell *c = (IGYearCell *)cell;
		
		[c updateCellWithYear:self.years[indexPath.row]];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    UIViewController *y = nil;
    
    if(indexPath.section == 0) {
        if (indexPath.row == 1) {
            y = RLHistoryViewController.new;
        }
        else {
            y = [RLShowSourcesViewController.alloc initWithRandomDate];
        }
    }
    else {
        y = [RLShowCollectionViewController.alloc initWithYear:self.years[indexPath.row]];
    }
    
    [self.navigationController pushViewController:y
                                         animated:YES];
}

@end
