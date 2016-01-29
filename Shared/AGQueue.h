//
//  AGQueue.h
//  PhishOD
//
//  Created by Alec Gorge on 1/29/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGQueue<__covariant ObjectType> : NSObject

@property (nonatomic) NSMutableArray *queue;

- (NSInteger)count;

- (void)enqueue:(ObjectType)object;
- (ObjectType)dequeue;

- (void)removeAllObjects;

- (BOOL)isEmpty;

@end
