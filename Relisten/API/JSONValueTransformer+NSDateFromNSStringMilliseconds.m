//
//  JSONModel+JSONModel_NSDateFromNSStringMilliseconds.m
//  PhishOD
//
//  Created by Alec Gorge on 7/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import "JSONValueTransformer+NSDateFromNSStringMilliseconds.h"

@implementation JSONValueTransformer (NSDateFromNSStringMilliseconds)

-(NSDateFormatter*)importDateFormatterNew
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZZZ"];
    });
    return inputDateFormatter;
}

-(NSDateFormatter*)millisecondImportDateFormatter
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmss.SSSZZZ"];
    });
    return inputDateFormatter;
}

- (NSDate *)NSDateFromNSString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@""]; // this is such an ugly code, is this the only way?
    NSDate *date = [self.importDateFormatterNew dateFromString: string];
    
    if(date) {
        return date;
    }
    
    return [self.millisecondImportDateFormatter dateFromString:string];
}

-(NSString*)JSONObjectFromNSDate:(NSDate*)date
{
    static dispatch_once_t onceOutput;
    static NSDateFormatter *outputDateFormatter;
    dispatch_once(&onceOutput, ^{
        outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [outputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    });
    return [outputDateFormatter stringFromDate:date];
}

@end
