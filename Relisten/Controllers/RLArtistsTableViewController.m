//
//  RLArtistsTableViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 6/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "RLArtistsTableViewController.h"

#import <ObjectiveSugar/ObjectiveSugar.h>

#import "RLArtistTabViewController.h"
#import "IGAPIClient.h"
#import "AppDelegate.h"
#import "RLSettingsViewController.h"
#import "PHODPersistence.h"

typedef NS_ENUM(NSInteger, RLArtistsSections) {
	RLArtistsFeaturedSection,
	RLArtistsAllSection,
	RLArtistsSectionsCount
};

static NSArray *featuredArtists;

@interface RLArtistsTableViewController ()

@property (nonatomic) NSArray *featuredArtists;
@property (nonatomic) NSArray *artists;

@property (nonatomic) BOOL shouldAutoshow;

@end

@implementation RLArtistsTableViewController

+ (void)initialize {
	featuredArtists = @[@"Grateful Dead",
						@"Marco Benevento",
						@"Phish",
						@"Phil Lesh and Friends",
						@"String Cheese Incident",
						@"Umphrey's McGee",
						];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Relisten";
    self.shouldAutoshow = YES;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem.alloc initWithImage:[UIImage settingsNavigationIcon]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(showSettings)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.shouldAutoshow) {
        IGAPIClient.sharedInstance.artist = [PHODPersistence.sharedInstance objectForKey:@"current_artist"];
        
        if(IGAPIClient.sharedInstance.artist != nil) {
            [self performSelector:@selector(presentArtistTabs:)
                       withObject:@(NO)
                       afterDelay:0.0];
        }
        
        self.shouldAutoshow = NO;
    }
}

- (void)showSettings {
    UINavigationController *navController = [UINavigationController.alloc initWithRootViewController:RLSettingsViewController.new];
    
    [AppDelegate.sharedDelegate.tabs presentViewController:navController
                                                  animated:YES
                                                completion:nil];
}

- (void)refresh:(id)sender {
    self.artists = [PHODPersistence.sharedInstance objectForKey:@"artists_alpha"];
    self.featuredArtists = [PHODPersistence.sharedInstance objectForKey:@"artists_featured"];
    
    if(self.artists != nil && self.featuredArtists != nil) {
        [self.tableView reloadData];
        [super refresh:sender];
    }
    
	[IGAPIClient.sharedInstance artists:^(NSArray *a) {
		self.artists = [a sortedArrayUsingComparator:^NSComparisonResult(IGArtist *obj1,
																		 IGArtist *obj2) {
			
			return [obj1.name compare:obj2.name
							  options:NSCaseInsensitiveSearch];
		}];
		
		self.featuredArtists = [featuredArtists map:^id(NSString *object) {
			return [self.artists find:^BOOL(IGArtist *artist) {
				return [artist.name isEqualToString:object];
			}];
		}];
        
        [PHODPersistence.sharedInstance setObject:self.artists
                                           forKey:@"artists_alpha"];
        
        [PHODPersistence.sharedInstance setObject:self.featuredArtists
                                           forKey:@"artists_featured"];
		
		[self.tableView reloadData];
		[super refresh:sender];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RLArtistsSectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if (self.artists) {
		if (section == RLArtistsFeaturedSection) {
			return self.featuredArtists.count;
		}
		else if(section == RLArtistsAllSection) {
			return self.artists.count;
		}
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	if (self.artists) {
		if (section == RLArtistsFeaturedSection) {
			return @"Feature";
		}
		else if(section == RLArtistsAllSection) {
			return [NSString stringWithFormat:@"All %ld artists", self.artists.count];
		}
	}
	
	return nil;
}

- (IGArtist *)artistForIndexPath:(NSIndexPath *)indexPath {
	IGArtist *artist = nil;
	
	if(indexPath.section == RLArtistsFeaturedSection) {
		artist = self.featuredArtists[indexPath.row];
	}
	else {
		artist = self.artists[indexPath.row];
	}
	
	return artist;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if(cell == nil) {
		cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
									reuseIdentifier:@"cell"];
	}
	
	IGArtist *artist = [self artistForIndexPath:indexPath];
	
	cell.textLabel.text = artist.name;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", artist.recordingCount];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	IGAPIClient.sharedInstance.artist = [self artistForIndexPath:indexPath];
    
    [PHODPersistence.sharedInstance setObject:IGAPIClient.sharedInstance.artist
                                       forKey:@"current_artist"];

    [self presentArtistTabs: @(YES)];
}

- (void)presentArtistTabs:(NSNumber *)animated {
    RLArtistTabViewController *vc = RLArtistTabViewController.new;
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    AppDelegate.sharedDelegate.tabs = vc;
    
    [self.navigationController presentViewController:vc
                                            animated:animated.boolValue
                                          completion:nil];
}

@end
