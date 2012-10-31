#import "CDRExampleGroup.h"

@interface CDRExampleGroup (Private)
- (void)startObservingExamples;
- (void)stopObservingExamples;
@end

@implementation CDRExampleGroup

@synthesize examples = examples_;

+ (id)groupWithText:(NSString *)text {
    return [[[[self class] alloc] initWithText: text] autorelease];
}

- (id)initWithText:(NSString *)text {
    return [self initWithText:text isRoot:NO];
}

- (id)initWithText:(NSString *)text isRoot:(BOOL)isRoot {
    if (self = [super initWithText:text]) {
        beforeBlocks_ = [[NSMutableArray alloc] init];
        examples_ = [[NSMutableArray alloc] init];
        afterBlocks_ = [[NSMutableArray alloc] init];
        isRoot_ = isRoot;
    }
    return self;
}

- (void)dealloc {
    [afterBlocks_ release];
    [examples_ release];
    [beforeBlocks_ release];
    [super dealloc];
}

#pragma mark Public interface
- (NSString *)description {
    return [NSString stringWithFormat:@"Example Group: %@", self.text];
}

- (void)add:(CDRExampleBase *)example {
    example.parent = self;
    [examples_ addObject:example];
}

- (void)addBefore:(CDRSpecBlock)block {
    CDRSpecBlock blockCopy = [block copy];
    [beforeBlocks_ addObject:blockCopy];
    [blockCopy release];
}

- (void)addAfter:(CDRSpecBlock)block {
    CDRSpecBlock blockCopy = [block copy];
    [afterBlocks_ addObject:blockCopy];
    [blockCopy release];
}

#pragma mark CDRExampleBase
- (CDRExampleState)state {
    if (0 == [examples_ count]) {
        return CDRExampleStatePending;
    }

    CDRExampleState aggregateState = CDRExampleStateIncomplete;
    for (CDRExampleBase *example in examples_) {
        aggregateState |= [example state];
    }
    return aggregateState;
}

- (float)progress {
    if (0 == [examples_ count]) {
        return 1.0;
    }

    float aggregateProgress = 0.0;
    for (CDRExampleBase *example in examples_) {
        aggregateProgress += [example progress];
    }
    return aggregateProgress / [examples_ count];
}

- (void)run {
    NSDate *startDate = [[NSDate alloc] init];
    [self startObservingExamples];
    [examples_ makeObjectsPerformSelector:@selector(run)];
    [self stopObservingExamples];
    runTime_ = -[startDate timeIntervalSinceNow];
    [startDate release];
}

- (BOOL)hasFocusedExamples {
    if (self.isFocused) {
        return YES;
    }
    for (CDRExampleBase *example in examples_) {
        if ([example hasFocusedExamples]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasChildren {
    return [examples_ count] > 0;
}

#pragma mark CDRExampleParent
- (void)setUp {
    [parent_ setUp];
    for (CDRSpecBlock beforeBlock in beforeBlocks_) {
        beforeBlock();
    }
}

- (void)tearDown {
    for (CDRSpecBlock afterBlock in afterBlocks_) {
        afterBlock();
    }
    [parent_ tearDown];
}

- (BOOL)hasFullText {
    return !isRoot_;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self willChangeValueForKey:@"state"];
    [self didChangeValueForKey:@"state"];
}

#pragma mark Private interface
- (void)startObservingExamples {
    for (id example in examples_) {
        [example addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
}
- (void)stopObservingExamples {
    for (id example in examples_) {
        [example removeObserver:self forKeyPath:@"state"];
    }
}

@end
