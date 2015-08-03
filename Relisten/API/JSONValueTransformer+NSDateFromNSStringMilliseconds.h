//
//  JSONModel+JSONModel_NSDateFromNSStringMilliseconds.h
//  PhishOD
//
//  Created by Alec Gorge on 7/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "JSONModel.h"

@interface JSONValueTransformer (NSDateFromNSStringMilliseconds)

-(NSDate*)NSDateFromNSString:(NSString*)string;
-(NSString*)JSONObjectFromNSDate:(NSDate*)date;

@end
