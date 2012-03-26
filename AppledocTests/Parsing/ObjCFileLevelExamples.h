//
//  top of file comment
//
//  Created by Tomaž Kragelj on 3/7/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#pragma mark - General top level stuff

#import <Foundation/Foundation.h>
#import "MyFile.h"

#define MY_VALUE
#define MY_MACRO(arg) do something with 'arg'
#define MY_MACRO(arg) do it \
	in multiple \
	lines

@class SomeExternalClass;
@protocol SomeExternalProtocol;

#pragma mark - Classes

@interface MyClass
@end

@interface MyClass <SomeProtocol>
@end

@interface MyClass <SomeProtocol1, SomeProtocol2, SomeProtocol3>
@end

@interface MyClass : NSObject
@end

@interface MyClass : NSObject <SomeProtocol>
@end

@interface MyClass : NSObject <SomeProtocol1, SomeProtocol2, SomeProtocol3>
@end

@implementation MyClass
@end

#pragma mark - Categories

@interface MyClass ()
@end

@interface MyClass (MyCategory)
@end

@implementation MyClass (MyCategory)
@end

#pragma mark - Protocols

@protocol MyProtocol
@end

@protocol MyProtocol <SomeProtocol>
@end

@protocol MyProtocol <SomeProtocol1, SomeProtocol2, SomeProtocol3>
@end

#pragma mark - Enumerations

enum {
	MyValue1,
	MyValue2
};
typedef NSUInteger MyValues;

typedef enum {
	MyValue1,
	MyValue2
} MyValues;

enum {
	MyValue1 = 10,
	MyValue2 = 25,
	MyValue3,
	MyValue4 = 60
} MyValues;

#pragma mark - Structs

struct MyStruct {
	BOOL field1;
	NSUInteger field2;
	__unsafe_unretained NSString *field3;
} MyStruct;

struct MyStruct MyStruct = {
	.field1 = NO,
	.field2 = 12,
	.field3 = @"hello"
};

#pragma mark - Constants

extern static const NSString *MyConstant;
extern static NSString * const MyConstant;
extern id MyConstant;

static const NSString *MyConstant = @"hello";
static NSString * const MyConstant = @"whatever";
if MyConstant = @"value";
