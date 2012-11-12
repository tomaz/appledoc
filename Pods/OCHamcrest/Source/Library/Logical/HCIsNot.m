//
//  OCHamcrest - HCIsNot.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsNot.h"

#import "HCDescription.h"
#import "HCWrapInMatcher.h"


@implementation HCIsNot

+ (id)isNot:(id<HCMatcher>)aMatcher
{
    return [[[self alloc] initNot:aMatcher] autorelease];
}

- (id)initNot:(id<HCMatcher>)aMatcher
{
    self = [super init];
    if (self)
        matcher = [aMatcher retain];
    return self;
}

- (void)dealloc
{
    [matcher release];
    [super dealloc];
}

- (BOOL)matches:(id)item
{
    return ![matcher matches:item];
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"not "] appendDescriptionOf:matcher];
}

@end


#pragma mark -

id<HCMatcher> HC_isNot(id aMatcher)
{
    return [HCIsNot isNot:HCWrapInMatcher(aMatcher)];
}
