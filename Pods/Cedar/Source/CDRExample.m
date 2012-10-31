#import "CDRExample.h"
#import "CDRExampleReporter.h"
#import "CDRSpecFailure.h"
#import "SpecHelper.h"

const CDRSpecBlock PENDING = nil;

@interface CDRExample (Private)
- (void)setState:(CDRExampleState)state;
@end

@implementation CDRExample

@synthesize failure = failure_;

+ (id)exampleWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
    return [[[[self class] alloc] initWithText:text andBlock:block] autorelease];
}

- (id)initWithText:(NSString *)text andBlock:(CDRSpecBlock)block {
    if (self = [super initWithText:text]) {
        block_ = [block copy];
        state_ = CDRExampleStateIncomplete;
    }
    return self;
}

- (void)dealloc {
    [block_ release];
    [super dealloc];
}

#pragma mark CDRExampleBase
- (CDRExampleState)state {
    return state_;
}

- (NSString *)message {
    if (self.failure.reason) {
        return self.failure.reason;
    }
    return [super message];
}

- (float)progress {
    if (self.state == CDRExampleStateIncomplete) {
        return 0.0;
    } else {
        return 1.0;
    }
}

- (void)run {
    NSDate *startDate = [[NSDate alloc] init];
    if (!self.shouldRun) {
        self.state = CDRExampleStateSkipped;
    } else if (block_) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        @try {
            [parent_ setUp];
            block_();
            self.state = CDRExampleStatePassed;
        } @catch (CDRSpecFailure *x) {
            self.failure = x;
            self.state = CDRExampleStateFailed;
        } @catch (NSObject *x) {
            self.failure = [CDRSpecFailure specFailureWithRaisedObject:x];
            self.state = CDRExampleStateError;
        }
        [parent_ tearDown];
        [pool drain];
    } else {
        self.state = CDRExampleStatePending;
    }
    runTime_ = -[startDate timeIntervalSinceNow];
    [startDate release];
}

#pragma mark Private interface
- (void)setState:(CDRExampleState)state {
    state_ = state;
}

@end
