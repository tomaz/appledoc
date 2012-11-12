//
//  OCMockito - MKTMockingProgress.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>

#import "MKTTestLocation.h"

@class MKTInvocationMatcher;
@class MKTOngoingStubbing;
@protocol HCMatcher;
@protocol MKTVerificationMode;


@interface MKTMockingProgress : NSObject

@property (nonatomic, assign) MKTTestLocation testLocation;

+ (id)sharedProgress;

- (void)stubbingStartedAtLocation:(MKTTestLocation)location;
- (void)reportOngoingStubbing:(MKTOngoingStubbing *)theOngoingStubbing;
- (MKTOngoingStubbing *)pullOngoingStubbing;

- (void)verificationStarted:(id <MKTVerificationMode>)mode atLocation:(MKTTestLocation)location;
- (id <MKTVerificationMode>)pullVerificationMode;

- (void)setMatcher:(id <HCMatcher>)matcher forArgument:(NSUInteger)index;
- (MKTInvocationMatcher *)pullInvocationMatcher;

@end
