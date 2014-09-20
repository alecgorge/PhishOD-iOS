//
//  CuratedPlaylistsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/6/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "CuratedPlaylistsViewController.h"

#import "PlaylistViewController.h"

@interface CuratedPlaylistsViewController ()

@property (nonatomic) NSArray *playlistGroups;

@end

@implementation CuratedPlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Curated Playlists";
}

- (void)refresh:(id)sender {
    [PhishinAPI.sharedAPI curatedPlaylists:^(NSArray *playlists) {
        self.playlistGroups = playlists;
        
        [self.tableView reloadData];
        [super refresh:sender];
    }
                                   failure:REQUEST_FAILED(self.tableView)];
}

- (PhishinPlaylistGroup *)groupForSection:(NSInteger)section {
    return self.playlistGroups[section];
}

- (PhishinPlaylistStub *)stubForIndexPath:(NSIndexPath *)indexPath {
    return [self groupForSection:indexPath.section].playlistStubs[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.playlistGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self groupForSection:section].playlistStubs.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return nil;
    }
    
    return [self groupForSection:section].title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if(!cell) {
        cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
                                    reuseIdentifier:@"cell"];
    }
    
    PhishinPlaylistStub *stub = [self stubForIndexPath:indexPath];
    
    cell.textLabel.text = stub.name;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    
    cell.detailTextLabel.text = [@"organized by " stringByAppendingString:stub.phishinAuthor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhishinPlaylistStub *stub = [self stubForIndexPath:indexPath];
    
    CGRect r = [stub.name boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 15 * 2, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0f]}
                                       context:nil];
    
    return MAX((tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight) * 1.2, 7 + r.size.height + 20 + 7);
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    PhishinPlaylistStub *stub = [self stubForIndexPath:indexPath];
    PlaylistViewController *vc = [PlaylistViewController.alloc initWithPlaylistStub:stub];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
