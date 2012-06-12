#import "CDROTestHelper.h"
#import <objc/runtime.h>

// This is exact copy of SenTestProbe +runTests: (https://github.com/jy/SenTestingKit/blob/master/SenTestProbe.m)
// except that it does not call exit() at the end.
int CDRRunOCUnitTests(id self, SEL _cmd, id ignored) {
    BOOL hasFailed = NO;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [[NSBundle allFrameworks] makeObjectsPerformSelector:@selector(principalClass)];
    [NSClassFromString(@"SenTestObserver") class];

    id testSuite = [self performSelector:@selector(specifiedTestSuite)];
    id runResult = [testSuite performSelector:@selector(run)];
    hasFailed = !(BOOL)[runResult performSelector:@selector(hasSucceeded)];

    [pool release];
    return (int)hasFailed;
}

// Hijack SenTestProble runTests: class method and run our specs instead.
// See https://github.com/jy/SenTestingKit for more information.
void CDRHijackOCUnitRun(IMP newImplementation) {
    Class senTestProbeClass = objc_getClass("SenTestProbe");
    if (senTestProbeClass) {
        Class senTestProbeMetaClass = objc_getMetaClass("SenTestProbe");
        class_replaceMethod(senTestProbeMetaClass, @selector(runTests:), newImplementation, "v@:@");
    }
}
