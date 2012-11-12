//
//  OCHamcrest - HCIsIn.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsIn.h"

#import "HCDescription.h"


@implementation HCIsIn

+ (id)isInCollection:(id)aCollection
{
    return [[[self alloc] initWithCollection:aCollection] autorelease];
}

- (id)initWithCollection:(id)aCollection
{
    if (![aCollection respondsToSelector:@selector(containsObject:)])
    {
        @throw [NSException exceptionWithName:@"NotAContainer"
                                       reason:@"Object must respond to -containsObject:"
                                     userInfo:nil];
    }
    
    self = [super init];
    if (self)
        collection = [aCollection retain];
    return self;
}

- (void)dealloc
{
    [collection release];
    [super dealloc];
}

- (BOOL)matches:(id)item
{
    return [collection containsObject:item];
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendText:@"one of "];
    [description appendList:collection start:@"{" separator:@", " end:@"}"];
}

@end


#pragma mark -

id<HCMatcher> HC_isIn(id aCollection)
{
    return [HCIsIn isInCollection:aCollection];
}
