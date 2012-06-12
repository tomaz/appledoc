#import "CDROTestRunner.h"
#import "CDROTestHelper.h"
#import "CDRFunctions.h"

@implementation CDROTestRunner

void CDRRunTests(id self, SEL _cmd, id ignored) {
    int exitStatus = CDRRunOCUnitTests(self, _cmd, ignored);

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Since we want to have integration with XCode when running tests from inside the IDE
    // CDROTestReporter needs to be default reporter; however, we can use any other reporter
    // when running from the command line (e.g. CDRColorizedReporter).
    NSArray *reporters = CDRReportersFromEnv("CDROTestReporter");
    if (![reporters count]) {
        exit(-999);
    }

    exitStatus |= runSpecsWithCustomExampleReporters(reporters);

    // otest always returns 0 as its exit code even if any test fails;
    // we need to forcibly exit with correct exit code to make CI happy.
    [pool drain];

    exit(exitStatus);
}

+ (void)load {
    CDRHijackOCUnitRun((IMP)CDRRunTests);
}

@end
