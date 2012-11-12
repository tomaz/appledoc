//
//  OCHamcrest - HCIsInstanceOf.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsInstanceOf.h"

#import "HCDescription.h"
#import "HCRequireNonNilObject.h"


@implementation HCIsInstanceOf

+ (id)isInstanceOf:(Class)type
{
    return [[[self alloc] initWithType:type] autorelease];
}

- (id)initWithType:(Class)aClass
{
    HCRequireNonNilObject(aClass);

    self = [super init];
    if (self)
        theClass = aClass;
    return self;
}

- (BOOL)matches:(id)item
{
    return [item isKindOfClass:theClass];
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"an instance of "]
                  appendText:NSStringFromClass(theClass)];
}

@end


#pragma mark -

id<HCMatcher> HC_instanceOf(Class aClass)
{
    return [HCIsInstanceOf isInstanceOf:aClass];
}
