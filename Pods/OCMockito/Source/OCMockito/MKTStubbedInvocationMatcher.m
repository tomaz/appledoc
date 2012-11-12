//
//  OCMockito - MKTStubbedInvocationMatcher.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTStubbedInvocationMatcher.h"


@implementation MKTStubbedInvocationMatcher

@synthesize answer;

- (void)dealloc
{
    [answer release];
    [super dealloc];
}

@end
