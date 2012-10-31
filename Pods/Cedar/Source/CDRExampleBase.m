#import "CDRExampleBase.h"
#import "SpecHelper.h"

@implementation CDRExampleBase

@synthesize text = text_, parent = parent_, focused = focused_, stackAddress = stackAddress_;

- (id)initWithText:(NSString *)text {
    if (self = [super init]) {
        text_ = [text retain];
        focused_ = NO;
        runTime_ = 0;
    }
    return self;
}

- (void)dealloc {
    [text_ release];
    [super dealloc];
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)run {
}

- (BOOL)shouldRun {
    BOOL shouldOnlyRunFocused = [SpecHelper specHelper].shouldOnlyRunFocused;
    return !shouldOnlyRunFocused || (shouldOnlyRunFocused && (self.isFocused || parent_.shouldRun));
}

- (BOOL)hasFocusedExamples {
    return self.isFocused;
}

- (BOOL)hasChildren {
    return NO;
}

- (NSString *)message {
    return @"";
}

- (NSString *)fullText {
    return [[self fullTextInPieces] componentsJoinedByString:@" "];
}

- (NSMutableArray *)fullTextInPieces {
    if (self.parent && [self.parent hasFullText]) {
        NSMutableArray *array = [self.parent fullTextInPieces];
        [array addObject:self.text];
        return array;
    } else {
        return [NSMutableArray arrayWithObject:self.text];
    }
}

- (NSTimeInterval)runTime {
    return runTime_;
}

@end
