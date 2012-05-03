#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@protocol CDRExampleReporter;
@class CDRExampleGroup, CDRExample, SpecHelper;

@protocol CDRSpec
@end

extern const CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
void beforeEach(CDRSpecBlock);
void afterEach(CDRSpecBlock);

CDRExampleGroup * describe(NSString *, CDRSpecBlock);
CDRExampleGroup * context(NSString *, CDRSpecBlock);
CDRExample * it(NSString *, CDRSpecBlock);

CDRExampleGroup * xcontext(NSString *, CDRSpecBlock);
CDRExampleGroup * xdescribe(NSString *, CDRSpecBlock);
CDRExample * xit(NSString *, CDRSpecBlock);

CDRExampleGroup * fdescribe(NSString *, CDRSpecBlock);
CDRExampleGroup * fcontext(NSString *, CDRSpecBlock);
CDRExample * fit(NSString *, CDRSpecBlock);

void fail(NSString *);
#ifdef __cplusplus
}

#import "ActualValue.h"
#import "ShouldSyntax.h"
#import "CedarComparators.h"
#import "CedarMatchers.h"
#import "CedarDoubles.h"

#endif // __cplusplus

@interface CDRSpec : NSObject <CDRSpec> {
  CDRExampleGroup *rootGroup_;
  CDRExampleGroup *currentGroup_;
}

@property (nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;
- (void)defineBehaviors;
@end

@interface CDRSpec (SpecDeclaration)
- (void)declareBehaviors;
@end

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \
- (void)declareBehaviors {

#define SPEC_END                     \
}                                    \
@end
