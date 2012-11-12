//
//  OCHamcrest - HCStringDescription.m
//  Copyright 2012 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCStringDescription.h"

#import "HCSelfDescribing.h"


@implementation HCStringDescription

+ (NSString *)stringFrom:(id<HCSelfDescribing>)selfDescribing
{
    HCStringDescription *description = [HCStringDescription stringDescription];
    [description appendDescriptionOf:selfDescribing];
    return [description description];
}

+ (HCStringDescription *)stringDescription
{
    return [[[HCStringDescription alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self)
        accumulator = [[NSMutableString alloc] init];
    return self;
}

- (void)dealloc
{
    [accumulator release];
    [super dealloc];
}

- (NSString *)description
{
    return accumulator;
}

- (void)append:(NSString *)str
{
    [accumulator appendString:str];
}

@end
