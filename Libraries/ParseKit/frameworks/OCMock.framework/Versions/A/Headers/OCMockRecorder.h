//---------------------------------------------------------------------------------------
//  $Id: OCMockRecorder.h 28 2008-06-19 22:37:17Z erik $
//  Copyright (c) 2004-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class OCMConstraint; // reference for backwards compatibility OCMOCK_ANY macro


@interface OCMockRecorder : NSProxy 
{
	id				signatureResolver;
	id				returnValue;
	BOOL			returnValueIsBoxed;
	BOOL			returnValueShouldBeThrown;
	NSInvocation	*recordedInvocation;
}

- (id)initWithSignatureResolver:(id)anObject;

- (id)andReturn:(id)anObject;
- (id)andReturnValue:(NSValue *)aValue;
- (id)andThrow:(NSException *)anException;

- (BOOL)matchesInvocation:(NSInvocation *)anInvocation;
- (void)setUpReturnValue:(NSInvocation *)anInvocation;
- (void)releaseInvocation;

@end

#define OCMOCK_ANY [OCMConstraint any]
#define OCMOCK_VALUE(variable) [NSValue value:&variable withObjCType:@encode(typeof(variable))]
