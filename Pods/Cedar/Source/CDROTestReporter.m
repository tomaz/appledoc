#import "CDROTestReporter.h"
#import "CDRFunctions.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"

@implementation CDROTestReporter

- (id)init {
    if ((self = [super init])) {
        failedExamples_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [failedExamples_ release];
    failedExamples_ = nil;
    [super dealloc];
}

- (void)reportOnExample:(CDRExample *)example {
    [super reportOnExample:example];

    if (example.state == CDRExampleStateError || example.state == CDRExampleStateFailed) {
        [failedExamples_ addObject:example];
    }
}

- (void)printStats {
    const char *startTimeString = [[startTime_ description] cStringUsingEncoding:NSUTF8StringEncoding];
    printf("Test Suite 'CDROTestReporter' started at %s\n", startTimeString);

    for (CDRExample *example in failedExamples_) {
        printf("Test Case '-[Spec example]' started.\n");
        NSString *testResult =
            [NSString stringWithFormat:@"%@:%d: error: -[Spec example] : %@ # %@",
                example.failure.fileName, example.failure.lineNumber, example.fullText, example.failure.reason];
        printf("%s\n", [testResult cStringUsingEncoding:NSUTF8StringEncoding]);
        printf("Test Case '-[Spec example]' failed (0.001 seconds).\n");
    }

    const char *endTimeString = [[endTime_ description] cStringUsingEncoding:NSUTF8StringEncoding];
    printf("Test Suite 'CDROTestReporter' finished at %s.\n", endTimeString);

    const char *testsString = exampleCount_ == 1 ? "test" : "tests";
    const char *failuresString = exampleCount_ == 1 ? "failure" : "failures";
    float totalTimeElapsed = [endTime_ timeIntervalSinceDate:startTime_];

    printf("Executed %u %s, with %u %s (0 unexpected) in %.4f (%.4f) seconds\n",
        exampleCount_, testsString, (unsigned int)failedExamples_.count, failuresString, totalTimeElapsed, totalTimeElapsed);
}

@end
