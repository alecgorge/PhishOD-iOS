//
//  LivePhishNote.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishNote.h"

#import <DBGHTMLEntities/DBGHTMLEntityDecoder.h>

@implementation LivePhishNote

- (NSString *)cleansedNote {
    DBGHTMLEntityDecoder *d = DBGHTMLEntityDecoder.alloc.init;
    NSString *str = [d decodeString:_note];
    return [str stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

@end
