//
//  IGTodayArtist.h
//  PhishOD
//
//  Created by Alec Gorge on 1/16/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import <JSONModel/JSONModel.h>

#import "IGTodayShow.h"

@interface IGTodayArtist : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *slug;
@property (nonatomic) NSArray<IGTodayShow> *shows;

@end
