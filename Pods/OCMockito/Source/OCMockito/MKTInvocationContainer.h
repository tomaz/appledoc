//
//  OCMockito - MKTInvocationContainer.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>

@class MKTMockingProgress;
@protocol HCMatcher;


@interface MKTInvocationContainer : NSObject

@property (nonatomic, readonly) NSMutableArray *registeredInvocations;

- (id)initWithMockingProgress:(MKTMockingProgress *)theMockingProgress;
- (void)setInvocationForPotentialStubbing:(NSInvocation *)invocation;
- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)argumentIndex;
- (void)addAnswer:(id)answer;
- (id)findAnswerFor:(NSInvocation *)invocation;

@end
