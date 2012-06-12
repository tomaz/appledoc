#import <Foundation/Foundation.h>

@protocol CDRSharedExampleGroupPool
@end

typedef void (^CDRSharedExampleGroupBlock)(NSDictionary *);

#ifdef __cplusplus
extern "C" {
#endif
void sharedExamplesFor(NSString *, CDRSharedExampleGroupBlock);
void itShouldBehaveLike(NSString *);
#ifdef __cplusplus
}
#endif

@interface CDRSharedExampleGroupPool : NSObject <CDRSharedExampleGroupPool>
@end

@interface CDRSharedExampleGroupPool (SharedExampleGroupDeclaration)
- (void)declareSharedExampleGroups;
@end

#define SHARED_EXAMPLE_GROUPS_BEGIN(name)                                \
@interface SharedExampleGroupPoolFor##name : CDRSharedExampleGroupPool   \
@end                                                                     \
@implementation SharedExampleGroupPoolFor##name                          \
- (void)declareSharedExampleGroups {

#define SHARED_EXAMPLE_GROUPS_END                                        \
}                                                                        \
@end
