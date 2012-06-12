#import "CDRColorizedReporter.h"

static const char * const ANSI_NORMAL = "\033[0m";
static const char * const ANSI_RED = "\033[0;40;31m";
static const char * const ANSI_GREEN = "\033[0;40;32m";
static const char * const ANSI_YELLOW = "\033[0;40;33m";
static const char * const ANSI_CYAN = "\033[0;40;36m";

@implementation CDRColorizedReporter

#pragma mark Protected interface
- (NSString *)successToken {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_GREEN, [super successToken], ANSI_NORMAL];
}

- (NSString *)pendingToken {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_YELLOW, [super pendingToken], ANSI_NORMAL];
}

- (NSString *)pendingMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_YELLOW, [super pendingMessageForExample:example], ANSI_NORMAL];
}

- (NSString *)skippedToken {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_CYAN, [super skippedToken], ANSI_NORMAL];
}

- (NSString *)skippedMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_CYAN, [super skippedMessageForExample:example], ANSI_NORMAL];
}

- (NSString *)failureToken {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_RED, [super failureToken], ANSI_NORMAL];
}

- (NSString *)failureMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_RED, [super failureMessageForExample:example], ANSI_NORMAL];
}

- (NSString *)errorToken {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_RED, [super errorToken], ANSI_NORMAL];
}

- (NSString *)errorMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%s%@%s", ANSI_RED, [super errorMessageForExample:example], ANSI_NORMAL];
}

@end
