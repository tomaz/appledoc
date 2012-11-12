//
//  OCMockito - MKTInvocationContainer.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTInvocationContainer.h"

#import "MKTStubbedInvocationMatcher.h"


@interface MKTInvocationContainer ()
@property (nonatomic, retain) MKTMockingProgress *mockingProgress;
@property (nonatomic, retain) MKTStubbedInvocationMatcher *invocationMatcherForStubbing;
@property (nonatomic, retain) NSMutableArray *stubbed;
@end


@implementation MKTInvocationContainer

@synthesize registeredInvocations;
@synthesize mockingProgress;
@synthesize invocationMatcherForStubbing;
@synthesize stubbed;

- (id)initWithMockingProgress:(MKTMockingProgress *)theMockingProgress
{
    self = [super init];
    if (self)
    {
        registeredInvocations = [[NSMutableArray alloc] init];
        mockingProgress = [theMockingProgress retain];
        stubbed = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [registeredInvocations release];
    [mockingProgress release];
    [invocationMatcherForStubbing release];
    [stubbed release];
    
    [super dealloc];
}

- (void)setInvocationForPotentialStubbing:(NSInvocation *)invocation
{
    [invocation retainArguments];
    [registeredInvocations addObject:invocation];
    
    MKTStubbedInvocationMatcher *stubbedInvocationMatcher = [[MKTStubbedInvocationMatcher alloc] init];
    [stubbedInvocationMatcher setExpectedInvocation:invocation];
    [self setInvocationMatcherForStubbing:stubbedInvocationMatcher];
    [stubbedInvocationMatcher release];
}

- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)argumentIndex
{
    [invocationMatcherForStubbing setMatcher:matcher atIndex:argumentIndex];
}

- (void)addAnswer:(id)answer
{
    [registeredInvocations removeLastObject];
    
    [invocationMatcherForStubbing setAnswer:answer];
    [stubbed insertObject:invocationMatcherForStubbing atIndex:0];
}

- (id)findAnswerFor:(NSInvocation *)invocation
{
    for (MKTStubbedInvocationMatcher *stubbedInvocationMatcher in stubbed)
        if ([stubbedInvocationMatcher matches:invocation])
            return [stubbedInvocationMatcher answer];
    
    return nil;
}

@end
