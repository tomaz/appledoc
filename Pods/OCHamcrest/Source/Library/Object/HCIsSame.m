//
//  OCHamcrest - HCIsSame.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsSame.h"

#import "HCDescription.h"


@implementation HCIsSame

+ (id)isSameAs:(id)anObject
{
    return [[[self alloc] initSameAs:anObject] autorelease];
}

- (id)initSameAs:(id)anObject
{
    self = [super init];
    if (self)
        object = [anObject retain];
    return self;
}

- (void)dealloc
{
    [object release];
    [super dealloc];
}

- (BOOL)matches:(id)item
{
    return item == object;
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [mismatchDescription appendText:@"was "];
    if (item)
        [mismatchDescription appendText:[NSString stringWithFormat:@"0x%0x ", item]];
    [mismatchDescription appendDescriptionOf:item];
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:[NSString stringWithFormat:@"same instance as 0x%0x ", object]]
         appendDescriptionOf:object];
}

@end


#pragma mark -

id<HCMatcher> HC_sameInstance(id object)
{
    return [HCIsSame isSameAs:object];
}
