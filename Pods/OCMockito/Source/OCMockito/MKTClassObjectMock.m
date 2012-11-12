//
//  OCMockito - MKTClassObjectMock.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: David Hart
//

#import "MKTClassObjectMock.h"


@interface MKTClassObjectMock ()
{
    Class mockedClass;
}
@end


@implementation MKTClassObjectMock

+ (id)mockForClass:(Class)aClass
{
    return [[[self alloc] initWithClass:aClass] autorelease];
}

- (id)initWithClass:(Class)aClass
{
    self = [super init];
    if (self)
        mockedClass = aClass;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [mockedClass methodSignatureForSelector:aSelector];
}


#pragma mark NSObject protocol

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [mockedClass respondsToSelector:aSelector];
}

@end
