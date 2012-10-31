#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@protocol CDRExampleReporter;
@class CDRExampleGroup, CDRExample, SpecHelper, CDRSymbolicator;

@protocol CDRSpec
@end

extern const CDRSpecBlock PENDING;

#ifdef __cplusplus
extern "C" {
#endif
void beforeEach(CDRSpecBlock);
void afterEach(CDRSpecBlock);

CDRExampleGroup * describe(NSString *, CDRSpecBlock);
extern CDRExampleGroup* (*context)(NSString *, CDRSpecBlock);
CDRExample * it(NSString *, CDRSpecBlock);

CDRExampleGroup * xdescribe(NSString *, CDRSpecBlock);
extern CDRExampleGroup* (*xcontext)(NSString *, CDRSpecBlock);
CDRExample * xit(NSString *, CDRSpecBlock);

CDRExampleGroup * fdescribe(NSString *, CDRSpecBlock);
extern CDRExampleGroup* (*fcontext)(NSString *, CDRSpecBlock);
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
    NSString *fileName_;
    CDRSymbolicator *symbolicator_;
}

@property (nonatomic, retain) CDRExampleGroup *currentGroup, *rootGroup;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) CDRSymbolicator *symbolicator;

- (void)defineBehaviors;
- (void)markAsFocusedClosestToLineNumber:(NSUInteger)lineNumber;
@end

@interface CDRSpec (SpecDeclaration)
- (void)declareBehaviors;
@end

#define SPEC_BEGIN(name)             \
@interface name : CDRSpec            \
@end                                 \
@implementation name                 \
- (void)declareBehaviors {           \
    self.fileName = [NSString stringWithUTF8String:__FILE__];

#define SPEC_END                     \
}                                    \
@end
