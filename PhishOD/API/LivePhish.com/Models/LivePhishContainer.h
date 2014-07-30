//
//  LivePhishContainer.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@protocol LivePhishContainer
@end

typedef NS_ENUM(NSInteger, LivePhishContainerType) {
    LivePhishContainerTypeShow,
    LivePhishContainerTypeAlbum
};

@interface LivePhishContainer : JSONModel

+ (NSDictionary *)keyMapperDict;

@property (nonatomic) LivePhishContainerType type;
@property (nonatomic) NSString<Optional> *venue;
@property (nonatomic) NSString<Optional> *date;
@property (nonatomic) NSString<Optional> *album;
@property (nonatomic) NSString<Optional> *containerInfo;

@property (nonatomic) NSString *artist;

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *relativeImagePath;
@property (nonatomic) NSString<Optional> *relativePagePath;

@property (nonatomic) UIImage<Ignore> *image;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSURL *livePhishPageURL;

@property (nonatomic, readonly) NSString *displayText;
@property (nonatomic, readonly) NSString *displaySubtext;
@property (nonatomic, readonly) NSString *displayTextWithDate;

@end
