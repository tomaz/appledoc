#import "CDRSlowTestStatistics.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"

@interface CDRRunTimeTitlePair : NSObject

@property (nonatomic, assign) NSTimeInterval runTime;
@property (nonatomic, retain) NSString *title;

+ (CDRRunTimeTitlePair *)pairWithRunTime:(NSTimeInterval)runTime title:(NSString *)title;
- (NSString *)formattedDescription;
@end

@implementation CDRRunTimeTitlePair

@synthesize runTime, title;

+ (CDRRunTimeTitlePair *)pairWithRunTime:(NSTimeInterval)runTime title:(NSString *)title {
    CDRRunTimeTitlePair *pair = [[[CDRRunTimeTitlePair alloc] init] autorelease];
    pair.runTime = runTime;
    pair.title = title;
    return pair;
}

- (void)dealloc {
    self.title = nil;
    [super dealloc];
}

- (NSString *)formattedDescription {
    NSString *timeString = [NSString stringWithFormat:@"%7.3fs | ", self.runTime];
    NSString *newLinePrefix = [NSString stringWithFormat:@"\n         | "];

    NSArray *titleChunks = [self.title componentsSeparatedByString:@" "];
    NSMutableArray *lines = [NSMutableArray array];
    NSMutableArray *currentLine = [NSMutableArray array];
    int currentLineLength = 0;

    for (NSString *titleChunk in titleChunks) {
        if (currentLineLength > 0 && (titleChunk.length + 1 + currentLineLength > 70)) {
            [lines addObject:[currentLine componentsJoinedByString:@" "]];
            currentLine = [NSMutableArray array];
            currentLineLength = 0;
        }

        [currentLine addObject:titleChunk];
        currentLineLength += titleChunk.length + 1;
    }

    [lines addObject:[currentLine componentsJoinedByString:@" "]];

    return [timeString stringByAppendingString:[lines componentsJoinedByString:newLinePrefix]];
}

- (NSComparisonResult)compare:(CDRRunTimeTitlePair *)otherPair {
    if (self.runTime > otherPair.runTime) {
        return NSOrderedDescending;
    } else if (self.runTime < otherPair.runTime) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

@end

@interface CDRSlowTestStatistics ()

- (int)numberOfResultsToShow;
- (NSArray *)runTimeTitlePairsForGroup:(CDRExampleGroup *)group;

@end

@implementation CDRSlowTestStatistics

- (int)numberOfResultsToShow {
    int numberOfResultsToShow = 10;
    if (getenv("CEDAR_TOP_N_SLOW_TESTS")) {
        numberOfResultsToShow = [[NSString stringWithUTF8String:getenv("CEDAR_TOP_N_SLOW_TESTS")] intValue];
    }
    return numberOfResultsToShow;
}

- (void)printStatsForExampleGroups:(NSArray *)groups {
    NSMutableArray *rootPairs = [NSMutableArray array];
    NSMutableArray *examplePairs = [NSMutableArray array];

    for (CDRExampleGroup *group in groups) {
        [rootPairs addObject:[CDRRunTimeTitlePair pairWithRunTime:group.runTime title:group.text]];
        [examplePairs addObjectsFromArray:[self runTimeTitlePairsForGroup:group]];
    }

    int numberOfResultsToShow = self.numberOfResultsToShow;

    NSArray *sortedRootPairs = [[[rootPairs sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    sortedRootPairs = [sortedRootPairs subarrayWithRange:NSMakeRange(0, MIN(numberOfResultsToShow, sortedRootPairs.count))];

    NSArray *sortedExamplePairs = [[[examplePairs sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    sortedExamplePairs = [sortedExamplePairs subarrayWithRange:NSMakeRange(0, MIN(numberOfResultsToShow, sortedExamplePairs.count))];

    printf("\n%d Slowest Tests\n\n", (int)sortedExamplePairs.count);
    for (CDRRunTimeTitlePair *pair in sortedExamplePairs) {
        printf("%s\n\n", pair.formattedDescription.UTF8String);
    }

    printf("\n%d Slowest Top-Level Groups\n\n", (int)sortedRootPairs.count);
    for (CDRRunTimeTitlePair *pair in sortedRootPairs) {
        printf("%s\n\n", pair.formattedDescription.UTF8String);
    }
}

- (NSArray *)runTimeTitlePairsForGroup:(CDRExampleGroup *)group {
    NSMutableArray *pairs = [NSMutableArray array];

    if (group.hasChildren) {
        for (CDRExampleBase *example in group.examples) {
            if (example.hasChildren) {
                [pairs addObjectsFromArray:[self runTimeTitlePairsForGroup:(CDRExampleGroup *) example]];
            } else {
                [pairs addObject:[CDRRunTimeTitlePair pairWithRunTime:example.runTime title:example.fullText]];
            }
        }
    }
    return pairs;
}

@end
