//
//  OCMockito - MKTMockingProgress.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTMockingProgress.h"

#import "MKTInvocationMatcher.h"
#import "MKTVerificationMode.h"


@interface MKTMockingProgress ()
@property (nonatomic, retain) MKTInvocationMatcher *invocationMatcher;
@property (nonatomic, retain) id <MKTVerificationMode> verificationMode;
@property (nonatomic, retain) MKTOngoingStubbing *ongoingStubbing;
@end


@implementation MKTMockingProgress

@synthesize testLocation;
@synthesize invocationMatcher;
@synthesize verificationMode;
@synthesize ongoingStubbing;

+ (id)sharedProgress
{
    static id sharedProgress = nil;
    
    if (!sharedProgress)
        sharedProgress = [[self alloc] init];
    return sharedProgress;
}

- (void)dealloc
{
    [invocationMatcher release];
    [verificationMode release];
    [ongoingStubbing release];
    [super dealloc];
}

- (void)stubbingStartedAtLocation:(MKTTestLocation)location
{
    [self setTestLocation:location];
}

- (void)reportOngoingStubbing:(MKTOngoingStubbing *)theOngoingStubbing
{
    [self setOngoingStubbing:theOngoingStubbing];
}

- (MKTOngoingStubbing *)pullOngoingStubbing
{
    MKTOngoingStubbing *result = [ongoingStubbing retain];
    [self setOngoingStubbing:nil];
    return [result autorelease];
}

- (void)verificationStarted:(id <MKTVerificationMode>)mode atLocation:(MKTTestLocation)location
{
    [self setVerificationMode:mode];
    [self setTestLocation:location];
}

- (id <MKTVerificationMode>)pullVerificationMode
{
    id <MKTVerificationMode> result = [verificationMode retain];
    [self setVerificationMode:nil];
    return [result autorelease];
}

- (void)setMatcher:(id <HCMatcher>)matcher forArgument:(NSUInteger)index
{
    if (!invocationMatcher)
        invocationMatcher = [[MKTInvocationMatcher alloc] init];
    [invocationMatcher setMatcher:matcher atIndex:index+2];
}

- (MKTInvocationMatcher *)pullInvocationMatcher
{
    MKTInvocationMatcher *result = [invocationMatcher retain];
    [self setInvocationMatcher:nil];
    return [result autorelease];
}

@end
