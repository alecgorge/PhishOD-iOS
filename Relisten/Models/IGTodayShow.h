//
//  IGTodayShow.h
//  PhishOD
//
//  Created by Alec Gorge on 1/16/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol IGTodayShow <NSObject>
@end

@interface IGTodayShow : JSONModel

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *display_date;
@property (nonatomic) NSInteger ArtistId;
@property (nonatomic) NSInteger year;

@end
