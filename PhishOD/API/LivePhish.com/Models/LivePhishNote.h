//
//  LivePhishNote.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@protocol LivePhishNote
@end

@interface LivePhishNote : JSONModel

@property (nonatomic) NSString *note;
@property (nonatomic, readonly) NSString *cleansedNote;

@end
