//---------------------------------------------------------------------------------------
//  $Id: OCMockObject.h 21 2008-01-24 18:59:39Z erik $
//  Copyright (c) 2004-2008 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface OCMockObject : NSProxy
{
	BOOL			isNice;
	NSMutableArray	*recorders;
	NSMutableSet	*expectations;
	NSMutableArray	*exceptions;
}

+ (id)mockForClass:(Class)aClass;
+ (id)mockForProtocol:(Protocol *)aProtocol;

+ (id)niceMockForClass:(Class)aClass;
+ (id)niceMockForProtocol:(Protocol *)aProtocol;

- (id)init;

- (id)stub;
- (id)expect;

- (void)verify;

@end
