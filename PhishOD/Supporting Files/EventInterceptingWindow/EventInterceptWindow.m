#import "EventInterceptWindow.h"

@implementation EventInterceptWindow

@synthesize eventInterceptDelegate;

- (void)sendEvent:(UIEvent *)event {
    if ([eventInterceptDelegate interceptEvent:event] == NO)
        [super sendEvent:event];
}

@end