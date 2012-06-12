#import <Foundation/Foundation.h>
#import "CDRDefaultReporter.h"

@interface CDRJUnitXMLReporter : CDRDefaultReporter {
    NSMutableArray *successMessages_;
}

@end
