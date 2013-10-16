//
//  YearsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearsViewController.h"
#import "YearViewController.h"

@interface YearsViewController ()

@end

@implementation YearsViewController

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.eras = @[];
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Years";
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] eras:^(NSArray *phishYears) {
		self.eras = phishYears;
		[self.tableView reloadData];
		
		[super refresh:sender];
	}
						  failure:REQUEST_FAILED(self.tableView)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.eras.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	PhishinEra *era = self.eras[section];
	return era.years.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	return [self.eras[section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	PhishinEra *era = self.eras[indexPath.section];
	cell.textLabel.text = ((PhishinYear*)era.years[indexPath.row]).year;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishinEra *era = self.eras[indexPath.section];
	PhishinYear *year = ((PhishinYear*)era.years[indexPath.row]);
    [self.navigationController pushViewController:[[YearViewController alloc] initWithYear:year]
										 animated:YES];
	
	[self.tableView deselectRowAtIndexPath:indexPath
								  animated:YES];
}

@end
