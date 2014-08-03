//
//  LivePhishDownloadQueueViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishDownloadQueueViewController.h"

#import <KVOController/FBKVOController.h>

#import "PHODTrackCell.h"

@interface LivePhishDownloadQueueViewController ()

@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) FBKVOController *kvo;

@end

@implementation LivePhishDownloadQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"Download Queue";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"trackCell"];
	
	self.queue = LivePhishDownloader.sharedInstance.queue;
    
    self.kvo = [FBKVOController.alloc initWithObserver:self];
    
    [self.kvo observe:self.queue
              keyPath:@"count"
              options:NSKeyValueObservingOptionNew
                block:^(id observer, id object, NSDictionary *change) {
                    [self.tableView reloadData];
                }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"%lu queued downloads", (unsigned long)self.queue.operations.count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.queue.operations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
														  forIndexPath:indexPath];
    
    if(indexPath.row >= self.queue.operations.count) {
        PHODDownloadOperation *op = self.queue.operations[indexPath.row];
        LivePhishDownloadItem *track = (LivePhishDownloadItem *)op.item;
        
        [cell updateCellWithTrack:track.song
                      inTableView:tableView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"];
    
	PHODDownloadOperation *op = self.queue.operations[indexPath.row];
	LivePhishDownloadItem *track = (LivePhishDownloadItem *)op.item;
	
    return [cell heightForCellWithTrack:track.song
							inTableView:tableView];
}

@end
