//
//  OCMockito - MKTInvocationMatcher.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTInvocationMatcher.h"

#define HC_SHORTHAND

#if TARGET_OS_MAC
    #import <OCHamcrest/OCHamcrest.h>
    #import <OCHamcrest/HCWrapInMatcher.h>
#else
    #import <OCHamcrestIOS/OCHamcrestIOS.h>
    #import <OCHamcrestIOS/HCWrapInMatcher.h>
#endif


@interface MKTInvocationMatcher ()
{
    NSUInteger numberOfArguments;
}
@property (nonatomic, retain) NSInvocation *expected;
@property (nonatomic, retain) NSMutableArray *argumentMatchers;
- (void)trueUpArgumentMatchersToCount:(NSUInteger)desiredCount;
@end


@implementation MKTInvocationMatcher

@synthesize expected;
@synthesize argumentMatchers;

- (id)init
{
    self = [super init];
    if (self)
        argumentMatchers = [[NSMutableArray alloc] init];
    return self;
}

- (void)dealloc
{
    [expected release];
    [argumentMatchers release];
    [super dealloc];
}

- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)argumentIndex
{
    NSUInteger matchersCount = [argumentMatchers count];
    if (matchersCount <= argumentIndex)
    {
        [self trueUpArgumentMatchersToCount:argumentIndex];
        [argumentMatchers addObject:matcher];
    }
    else
        [argumentMatchers replaceObjectAtIndex:argumentIndex withObject:matcher];
}

- (NSUInteger)argumentMatchersCount
{
    return [argumentMatchers count];
}

- (void)trueUpArgumentMatchersToCount:(NSUInteger)desiredCount
{
    NSUInteger matchersCount = [argumentMatchers count];
    while (matchersCount < desiredCount)
    {
        [argumentMatchers addObject:[NSNull null]];
        ++matchersCount;
    } 
}

- (void)setExpectedInvocation:(NSInvocation *)expectedInvocation
{
    [self setExpected:expectedInvocation];
    [expected retainArguments];
    
    NSMethodSignature *methodSignature = [expected methodSignature];
    
    numberOfArguments = [[expected methodSignature] numberOfArguments];
    [self trueUpArgumentMatchersToCount:numberOfArguments];
        
    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++argumentIndex)
    {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        if (strcmp(argumentType, @encode(id)) == 0)
        {
            id argument = nil;
            [expected getArgument:&argument atIndex:argumentIndex];
            
            id <HCMatcher> matcher;
            if (argument != nil)
                matcher = HCWrapInMatcher(argument);
            else
                matcher = nilValue();
            
            [self setMatcher:matcher atIndex:argumentIndex];
        }
    }
}

- (BOOL)argumentObjectMismatchInInvocation:(NSInvocation *)actual atIndex:(NSUInteger)index
{
    id actualArgument;
    [actual getArgument:&actualArgument atIndex:index];
    
    id <HCMatcher> matcher = [argumentMatchers objectAtIndex:index];
    return ![matcher matches:actualArgument];
}

#define DEFINE_ARGUMENT_MISMATCH_METHOD(type, typeName)                                     \
    - (BOOL)argument ## typeName ## MismatchInInvocation:(NSInvocation *)actual atIndex:(NSUInteger)index \
    {                                                                                       \
        type actualArgument;                                                                \
        [actual getArgument:&actualArgument atIndex:index];                                 \
                                                                                            \
        id <HCMatcher> matcher = [argumentMatchers objectAtIndex:index];                    \
        if ([matcher isEqual:[NSNull null]])                                                \
        {                                                                                   \
            type expectedArgument;                                                          \
            [expected getArgument:&expectedArgument atIndex:index];                         \
            return expectedArgument != actualArgument;                                      \
        }                                                                                   \
        else                                                                                \
            return ![matcher matches:[NSNumber numberWith ## typeName :actualArgument]];    \
    }

DEFINE_ARGUMENT_MISMATCH_METHOD(char, Char)
DEFINE_ARGUMENT_MISMATCH_METHOD(int, Int)
DEFINE_ARGUMENT_MISMATCH_METHOD(short, Short)
DEFINE_ARGUMENT_MISMATCH_METHOD(long, Long)
DEFINE_ARGUMENT_MISMATCH_METHOD(long long, LongLong)
DEFINE_ARGUMENT_MISMATCH_METHOD(unsigned char, UnsignedChar)
DEFINE_ARGUMENT_MISMATCH_METHOD(unsigned int, UnsignedInt)
DEFINE_ARGUMENT_MISMATCH_METHOD(unsigned short, UnsignedShort)
DEFINE_ARGUMENT_MISMATCH_METHOD(unsigned long, UnsignedLong)
DEFINE_ARGUMENT_MISMATCH_METHOD(unsigned long long, UnsignedLongLong)
DEFINE_ARGUMENT_MISMATCH_METHOD(float, Float)
DEFINE_ARGUMENT_MISMATCH_METHOD(double, Double)


#define HANDLE_ARGUMENT_TYPE(type, typeName)                                                    \
    else if (strcmp(argumentType, @encode(type)) == 0)                                          \
    {                                                                                           \
        if ([self argument ## typeName ## MismatchInInvocation:actual atIndex:argumentIndex])   \
            return NO;                                                                          \
    }

- (BOOL)matches:(NSInvocation *)actual
{
    if ([expected selector] != [actual selector])
        return NO;

    NSMethodSignature *methodSignature = [expected methodSignature];

    for (NSUInteger argumentIndex = 2; argumentIndex < numberOfArguments; ++argumentIndex)
    {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:argumentIndex];
        if (strcmp(argumentType, @encode(id)) == 0)
        {
            if ([self argumentObjectMismatchInInvocation:actual atIndex:argumentIndex])
                return NO;
        }
        HANDLE_ARGUMENT_TYPE(char, Char)
        HANDLE_ARGUMENT_TYPE(int, Int)
        HANDLE_ARGUMENT_TYPE(short, Short)
        HANDLE_ARGUMENT_TYPE(long, Long)
        HANDLE_ARGUMENT_TYPE(long long, LongLong)
        HANDLE_ARGUMENT_TYPE(unsigned char, UnsignedChar)
        HANDLE_ARGUMENT_TYPE(unsigned int, UnsignedInt)
        HANDLE_ARGUMENT_TYPE(unsigned short, UnsignedShort)
        HANDLE_ARGUMENT_TYPE(unsigned long, UnsignedLong)
        HANDLE_ARGUMENT_TYPE(unsigned long long, UnsignedLongLong)
        HANDLE_ARGUMENT_TYPE(float, Float)
        HANDLE_ARGUMENT_TYPE(double, Double)
    }
    
    return YES;
}

@end
