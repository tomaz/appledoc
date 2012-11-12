//
//  OCMockito - MKTExactTimes.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTExactTimes.h"

#import "MKTInvocationContainer.h"
#import "MKTInvocationMatcher.h"
#import "MKTTestLocation.h"
#import "MKTVerificationData.h"
#import "NSException+OCMockito.h"


// As of 2010-09-09, the iPhone simulator has a bug where you can't catch exceptions when they are
// thrown across NSInvocation boundaries. (See http://openradar.appspot.com/8081169 ) So instead of
// using an NSInvocation to call -failWithException: without linking in SenTestingKit, we simply
// pretend it exists on NSObject.
@interface NSObject (MTExceptionBugHack)
- (void)failWithException:(NSException *)exception;
@end


@interface MKTExactTimes ()
{
    NSUInteger expectedCount;
}
@end


@implementation MKTExactTimes

+ (id)timesWithCount:(NSUInteger)expectedNumberOfInvocations
{
    return [[[self alloc] initWithCount:expectedNumberOfInvocations] autorelease];
}

- (id)initWithCount:(NSUInteger)expectedNumberOfInvocations
{
    self = [super init];
    if (self)
        expectedCount = expectedNumberOfInvocations;
    return self;
}


#pragma mark MKTVerificationMode

- (void)verifyData:(MKTVerificationData *)data
{
    NSUInteger matchingCount = 0;
    for (NSInvocation *invocation in [[data invocations] registeredInvocations])
    {
        if ([[data wanted] matches:invocation])
            ++matchingCount;
    }
    
    if (matchingCount != expectedCount)
    {
        NSString *plural = (expectedCount == 1) ? @"" : @"s";
        NSString *description = [NSString stringWithFormat:@"Expected %d matching invocation%@, but received %d",
                                 expectedCount, plural, matchingCount];
        MKTFailTestLocation([data testLocation], description);
    }
}

@end
