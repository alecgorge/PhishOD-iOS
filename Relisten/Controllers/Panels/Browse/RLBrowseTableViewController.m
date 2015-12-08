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

#import "IGShowCell.h"

typedef NS_ENUM(NSInteger, RLBrowseSections) {
	RLBrowseRandomShowSection,
	RLBrowseYearSection,
	RLBrowseSectionsCount
};

@interface RLBrowseTableViewController ()

@property (nonatomic) NSArray *years;
@property (nonatomic) NSArray *shows;
@property (nonatomic) NSArray *tracks;
@property (nonatomic) NSArray *venues;

@property (nonatomic) BOOL inSearchMode;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation RLBrowseTableViewController

- (instancetype)init {
	if (self = [super init]) {
		self.tabBarItem = [UITabBarItem.alloc initWithTitle:@"Browse"
													  image:[UIImage imageNamed:@"glyphicons-58-history"]
														tag:0];
		
		self.navigationController.tabBarItem = self.tabBarItem;
        
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
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(IGShowCell.class)
                                               bundle:NSBundle.mainBundle]
         forCellReuseIdentifier:@"show"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 55.0f;
    
    UIBarButtonItem *closeBtn = [UIBarButtonItem.alloc initWithTitle:@"All Artists"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(close)];
    
    self.navigationItem.rightBarButtonItem = closeBtn;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.title = IGAPIClient.sharedInstance.artist.name;
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
    if (self.inSearchMode) {
        return 2;
    }
    
	return self.years ? RLBrowseSectionsCount : 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (self.inSearchMode) {
        if (section == 0) {
            return self.shows.count;
        } else {
            return self.venues.count;
        }
    }
    
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
    if (self.inSearchMode) {
        if (section == 0) {
            return @"Shows";
        }
        else {
            return @"Venues";
        }
    }
    
	if (section == RLBrowseYearSection) {
		return [NSString stringWithFormat:@"%ld years", self.years.count];
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.inSearchMode) {
        return UITableViewAutomaticDimension;
    }
    
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
    if (self.inSearchMode) {
        if(indexPath.section == 0) {
            IGShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"show"
                                                               forIndexPath:indexPath];
            
            [cell updateCellWithShow:self.shows[indexPath.row]];
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venue"];
            
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
    } else {
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    UIViewController *y = nil;
    
    if (self.inSearchMode) {
        if (indexPath.section == 0) {
            IGShow *show = self.shows[indexPath.row];
            y = [RLShowSourcesViewController.alloc initWithDisplayDate:show.displayDate];
        } else {
            y = [RLShowCollectionViewController.alloc initWithVenue:self.venues[indexPath.row]];
        }
    } else {
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
    }
    
    [self.navigationController pushViewController:y
                                         animated:YES];
}

#pragma mark - Search results updater

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length > 0) {
        [IGAPIClient.sharedInstance search:searchText success:^(NSArray *content) {
            self.shows = content[0];
            self.venues = content[1];
            
            [self.tableView reloadData];
        }];
    } else {
        self.shows = @[];
        self.venues = @[];
        [self.tableView reloadData];
    }
}

#pragma mark - Search bar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.inSearchMode = YES;
    [self.tableView reloadData];
    return true;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.inSearchMode = NO;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

@end
