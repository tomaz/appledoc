//
//  OCMockito - MKTVerificationData.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>

#import "MKTTestLocation.h"

@class MKTInvocationContainer;
@class MKTInvocationMatcher;


@interface MKTVerificationData : NSObject

@property (nonatomic, retain) MKTInvocationContainer *invocations;
@property (nonatomic, retain) MKTInvocationMatcher *wanted;
@property (nonatomic, assign) MKTTestLocation testLocation;

@end
