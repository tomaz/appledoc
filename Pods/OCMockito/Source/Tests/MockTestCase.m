//
//  OCMockito - MockTestCase.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MockTestCase.h"


@implementation MockTestCase

@synthesize failureCount;
@synthesize failureException;

- (void)dealloc
{
    [failureException release];
    [super dealloc];
}

- (void)failWithException:(NSException *)exception
{
    ++failureCount;
    [self setFailureException:exception];
}

@end
