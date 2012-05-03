#import <Foundation/Foundation.h>

@protocol CDRExampleReporter <NSObject>

- (void)runWillStartWithGroups:(NSArray *)groups;
- (void)runDidComplete;
- (int)result;

@end
