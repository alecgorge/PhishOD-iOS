//
//  AGQueue.m
//  PhishOD
//
//  Created by Alec Gorge on 1/29/16.
//  Copyright © 2016 Alec Gorge. All rights reserved.
//

#import "AGQueue.h"

@implementation AGQueue

- (NSInteger)count {
    return self.queue.count;
}

- (NSString *)description {
    return self.queue.description;
}

- (void)removeAllObjects {
    [self.queue removeAllObjects];
}

- (void)enqueue:(id)object {
    if(self.queue.count == 0) {
        self.queue = NSMutableArray.array;
    }
    
    [self.queue addObject:object];
}

- (id)dequeue {
    if(self.queue.count != 0) {
        // Get the object at index 0
        id object = [self.queue objectAtIndex:0];
        
        // Remove the object from index 0
        [self.queue removeObjectAtIndex:0];
        
        // Return the object
        return object;
    }
    else {
        return nil;
    }
}

- (BOOL)isEmpty {
    return self.queue.count == 0;
}

@end
