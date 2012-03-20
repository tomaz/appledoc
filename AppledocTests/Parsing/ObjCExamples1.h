//
//  header comment
//
//  Created by Tomaž Kragelj on 3/7/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#include <Foundation/Foundation.h>

@class SomeExternalClass;

/** A comment for MyClass.
 
 Here's second paragraph.
 */
@interface MyClass : NSObject <SomeProtocol>

/** Comment for method.
 
 @param value1 First parameter
 @param value2 Second parameter
 @return Returns a value.
 */
- (id)doSomethingWith:(id)value1 forSomethingElse:(id)value2;

/** Method testing var args.
 
 @param first First argument
 @param ... Comma separated, nil terminated values.
 */
- (void)methodWithVarArgs:(id)first, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Method group from header

- (void)method2;

@property (nonatomic, strong) NSString *value1;

@end

#pragma mark - 

@protocol SomeProtocol

- (void)methodWithoutGroup;

#pragma mark Methods that deal with X
#pragma mark - 

- (void)methodInsideGroup1;
- (void)methodInsideGroup2;

@end

#pragma mark - 

@interface AClass (ACategory)
- (id)methodFromCategory;
@end

#pragma mark - Below are various possibilities that demonstrate how C objects should be handled

/** Example of enumeration. */
enum {
	GBEnumValue1, ///< enum1
	GBEnumValue2, ///< enum2
};
typedef NSUInteger GBEnum;

/** namespaced constants */
extern const struct GBStruct {
	__unsafe_unretained NSString *value1; ///< struct1
	__unsafe_unretained NSString *value2; ///< struct2
} GBStruct;

extern NSString *GBConstant1; ///< constant1

/** function
 
 @param p1 First
 @param p2 Second
 @return Result
 */
extern id function1(id p1, id p2);
