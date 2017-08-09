//---------------------------------------------------------------------------------------
//  $Id: $
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface OCMArg : NSObject 

// constraining arguments

+ (id)any;
+ (void *)anyPointer;
+ (id)isNil;
+ (id)isNotNil;
+ (id)isNotEqual:(id)value;
+ (id)checkWithSelector:(SEL)selector onObject:(id)anObject;

// manipulating arguments

+ (id *)setTo:(id)value;

@end

#define OCMOCK_ANY [OCMArg any]
#define OCMOCK_VALUE(variable) [NSValue value:&variable withObjCType:@encode(typeof(variable))]
