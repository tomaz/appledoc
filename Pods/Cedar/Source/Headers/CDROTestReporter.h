#import <Foundation/Foundation.h>
#import "CDRDefaultReporter.h"

@interface CDROTestReporter : CDRDefaultReporter {
    NSMutableArray *failedExamples_;
}

@end
