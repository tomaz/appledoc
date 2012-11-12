//
//  OCMockito - MKTProtocolMock.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTProtocolMock.h"

#import <objc/runtime.h>


@interface MKTProtocolMock ()
{
    Protocol *mockedProtocol;
}
@end


@implementation MKTProtocolMock

+ (id)mockForProtocol:(Protocol *)aProtocol
{
    return [[[self alloc] initWithProtocol:aProtocol] autorelease];
}

- (id)initWithProtocol:(Protocol *)aProtocol
{
    self = [super init];
    if (self)
        mockedProtocol = aProtocol;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    struct objc_method_description methodDescription = protocol_getMethodDescription(mockedProtocol, aSelector, YES, YES);
    if (!methodDescription.name)
        methodDescription = protocol_getMethodDescription(mockedProtocol, aSelector, NO, YES);
    if (!methodDescription.name)
        return nil;
	return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}


#pragma mark NSObject protocol

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return protocol_conformsToProtocol(mockedProtocol, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self methodSignatureForSelector:aSelector] != nil;
}

@end
