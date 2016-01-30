//
//  PHODDownloadingTrackCell.h
//  PhishOD
//
//  Created by Alec Gorge on 1/29/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *PHODDownloadingTrackCellIdentifier;

@interface PHODDownloadingTrackCell : UITableViewCell

- (void)updateCellWithDownloadItem:(PHODDownloadItem *)item;

@end
