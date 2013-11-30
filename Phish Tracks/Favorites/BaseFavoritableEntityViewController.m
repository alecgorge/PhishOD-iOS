//
//  BaseFavoritableEntityViewController.m
//  Phish Tracks
//
//  Created by Alexander Bird on 11/24/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "BaseFavoritableEntityViewController.h"

@interface BaseFavoritableEntityViewController ()

@end

@implementation BaseFavoritableEntityViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(rightBarButtonAction)];
        
        self.navigationItem.rightBarButtonItem = editButtonItem;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshFavorites];
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void)rightBarButtonAction
{
    if (self.tableView.editing) {
        editButtonItem.style = UIBarButtonItemStylePlain;
        editButtonItem.title = @"Edit";
        [self.tableView setEditing:NO animated:YES];
    }
    else {
        editButtonItem.style = UIBarButtonItemStyleDone;
        editButtonItem.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}

- (NSString *)sectionIndexTitleForString:(NSString *)string
{
    NSString *firstLetter = [string substringToIndex:1];
    
    if (isalpha([firstLetter characterAtIndex:0])) {
        return firstLetter;
    }
    else {
        return @"#";
    }
}

- (void)buildSectionIndices:(NSArray *)favorites
{
    if (!favorites)
        return;
    
    NSMutableDictionary *sections = [[NSMutableDictionary alloc] init];
    
    favorites = [favorites sortedArrayUsingComparator:^NSComparisonResult(PhishTracksStatsFavorite *fav1, PhishTracksStatsFavorite *fav2) {
        return [[fav1 performSelector:sectionIndexTitlesSelector] compare:[fav2 performSelector:sectionIndexTitlesSelector]];
    }];
    
    for (PhishTracksStatsFavorite *favorite in favorites) {
        NSString *sectionIndexTitle = [self sectionIndexTitleForString:[favorite performSelector:sectionIndexTitlesSelector]];
        
        if (![sections hasKey:sectionIndexTitle])
            [sections setObject:[NSMutableArray array] forKey:sectionIndexTitle];
        
        [[sections objectForKey:sectionIndexTitle] addObject:favorite];
    }
    
    NSArray *sectionTitles = [[sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    NSLog(@"titles = %@", sectionTitles);
    self.sectionTitles = sectionTitles;
    self.sections = sections;
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark "Abstract" methods

- (void)refreshFavorites
{
#warning override in subclass
}

- (void)deleteActionForFavorite:(PhishTracksStatsFavorite *)favorite
{
#warning override in subclass
}

- (NSString *)textLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
#warning override in subclass
    return nil;
}

- (NSString *)detailTextLabelTextForFavorite:(PhishTracksStatsFavorite *)favorite
{
#warning override in subclass
    return nil;
}

- (UIViewController *)viewControllerToPushForFavorite:(PhishTracksStatsFavorite *)favorite
{
#warning override in subclass
    return nil;
}


#pragma mark -
#pragma mark UITableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [[self.sections objectForKey:[self.sectionTitles objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
    
    NSArray *section = [self.sections objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
    PhishTracksStatsFavorite *fav = [section objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self textLabelTextForFavorite:fav];
    cell.detailTextLabel.text = [self detailTextLabelTextForFavorite:fav];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *section = [self.sections objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
    PhishTracksStatsFavorite *fav = [section objectAtIndex:indexPath.row];
    UIViewController *c = [self viewControllerToPushForFavorite:fav];
    [self.navigationController pushViewController:c animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *st = [self.sectionTitles objectAtIndex:section];
    
    if ([st isEqualToString:@"#"]) {
        return @"123";
    }
    else {
        return st;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *section = [self.sections objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
        PhishTracksStatsFavorite *fav = [section objectAtIndex:indexPath.row];
        [section removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self deleteActionForFavorite:fav];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
