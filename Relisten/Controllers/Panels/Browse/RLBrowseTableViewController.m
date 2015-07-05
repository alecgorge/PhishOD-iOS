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
#import "RLYearViewController.h"

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
		return 1;
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
		return 88.0f;
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
		
		cell.textLabel.text = @"Random Show";
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
    
    RLYearViewController *y = [RLYearViewController.alloc initWithYear:self.years[indexPath.row]];
    
    [self.navigationController pushViewController:y
                                         animated:YES];
}

@end
