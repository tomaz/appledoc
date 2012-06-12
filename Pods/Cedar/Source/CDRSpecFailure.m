#import "CDRSpecFailure.h"
#import <regex.h>

@interface CDRSpecFailure ()
+ (void)extractReason:(NSString **)reason fileName:(NSString **)fileName lineNumber:(int *)lineNumber fromObject:(NSObject *)object;
+ (BOOL)extractReason:(NSString **)reason fileName:(NSString **)fileName lineNumber:(int *)lineNumber fromString:(NSString *)string;
@end


@implementation CDRSpecFailure

@synthesize fileName = fileName_, lineNumber = lineNumber_;

+ (id)specFailureWithReason:(NSString *)reason {
    return [[[self alloc] initWithReason:reason] autorelease];
}

+ (id)specFailureWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber {
    return [[[self alloc] initWithReason:reason fileName:fileName lineNumber:lineNumber] autorelease];
}

+ (id)specFailureWithRaisedObject:(NSObject *)object {
    return [[[self alloc] initWithRaisedObject:object] autorelease];
}

- (id)initWithReason:(NSString *)reason {
    return [self initWithRaisedObject:reason];
}

- (id)initWithReason:(NSString *)reason fileName:(NSString *)fileName lineNumber:(int)lineNumber {
    if ((self = [super initWithName:@"Spec Failure" reason:reason userInfo:nil])) {
        fileName_ = [fileName retain];
        lineNumber_ = lineNumber;
    }
    return self;
}

- (id)initWithRaisedObject:(NSObject *)object {
    NSString *fileName = nil;
    int lineNumber;
    NSString *reason = nil;
    [[self class] extractReason:&reason fileName:&fileName lineNumber:&lineNumber fromObject:object];

    if ((self = [super initWithName:@"Spec Failure" reason:[reason retain] userInfo:nil])) {
        fileName_ = [fileName retain];
        lineNumber_ = lineNumber;
    }
    return self;
}

- (void)dealloc {
    [fileName_ release];
    [super dealloc];
}

- (NSString *)description {
    if (self.fileName) {
        return [NSString stringWithFormat:@"%@:%d %@", self.fileName, self.lineNumber, self.reason];
    }
    return self.reason;
}

#pragma mark Private Interface
+ (void)extractReason:(NSString **)reason fileName:(NSString **)fileName lineNumber:(int *)lineNumber fromObject:(NSObject *)object {
    if ([object isKindOfClass:[NSException class]]) {
        NSDictionary *userInfo = [(NSException *)object userInfo];
        if ([userInfo objectForKey:@"fileName"] && [userInfo objectForKey:@"lineNumber"]) {
            *fileName = [userInfo objectForKey:@"fileName"];
            *lineNumber = [[userInfo objectForKey:@"lineNumber"] intValue];
            *reason = [(NSException *)object reason];
            return;
        }
    }

    if ([object isKindOfClass:[NSString class]]) {
        if ([self extractReason:reason fileName:fileName lineNumber:lineNumber fromString:(NSString *)object]) {
            return;
        }
    }

    *lineNumber = 0;
    *reason = [object description];
}

+ (BOOL)extractReason:(NSString **)reason fileName:(NSString **)fileName lineNumber:(int *)lineNumber fromString:(NSString *)string {
    static const char *variations[] = {
        "(.+):([[:digit:]]+)[[:space:]]+(.*)",             // File.m:123 reason
        "(.+)\\(([[:digit:]]+)\\):?[[:space:]]+(.*)"       // File.m(123): reason
    };

    const char *buf = [string UTF8String];

    for (int i=0; i<2; ++i) {
        regex_t rx;
        regmatch_t *matches;

        regcomp(&rx, variations[i], REG_EXTENDED);
        matches = (regmatch_t *)malloc((rx.re_nsub+1) * sizeof(regmatch_t));

        int result = regexec(&rx, buf, rx.re_nsub+1, matches, 0);
        if (!result) {
            *fileName = [[[NSString alloc] initWithBytes:(buf + matches[1].rm_so) length:(NSInteger)(matches[1].rm_eo - matches[1].rm_so) encoding:NSUTF8StringEncoding] autorelease];
            *lineNumber = [[[[NSString alloc] initWithBytes:(buf + matches[2].rm_so) length:(NSInteger)(matches[2].rm_eo - matches[2].rm_so) encoding:NSUTF8StringEncoding] autorelease] intValue];
            *reason = [[[NSString alloc] initWithBytes:(buf + matches[3].rm_so) length:(NSInteger)(matches[3].rm_eo - matches[3].rm_so) encoding:NSUTF8StringEncoding] autorelease];
        }

        free(matches);
        regfree(&rx);

        if (!result)
            return YES;
    }
    return NO;
}

@end
