@protocol EventInterceptWindowDelegate
- (BOOL)interceptEvent:(UIEvent *)event; // return YES if event handled
@end


@interface EventInterceptWindow : UIWindow

@property(nonatomic, assign)
id <EventInterceptWindowDelegate> eventInterceptDelegate;

@end