#import "CDRSpec.h"
#import "CDRSharedExampleGroupPool.h"
#import "CDRExampleParent.h"

@interface SpecHelper : NSObject <CDRExampleParent> {
    NSMutableDictionary *sharedExampleContext_, *sharedExampleGroups_;
    NSArray *globalBeforeEachClasses_, *globalAfterEachClasses_;
    BOOL shouldOnlyRunFocused_;
}

@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleContext;
@property (nonatomic, retain) NSArray *globalBeforeEachClasses, *globalAfterEachClasses;

@property (nonatomic, assign) BOOL shouldOnlyRunFocused;

+ (SpecHelper *)specHelper;

@end
