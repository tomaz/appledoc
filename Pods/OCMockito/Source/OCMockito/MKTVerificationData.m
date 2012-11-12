//
//  OCMockito - MKTVerificationData.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTVerificationData.h"


@implementation MKTVerificationData

@synthesize invocations;
@synthesize wanted;
@synthesize testLocation;

- (void)dealloc
{
    [invocations release];
    [wanted release];
    [super dealloc];
}

@end
