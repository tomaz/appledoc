//
//  GBMethodArgument.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Defines a single method argument. */
@interface GBMethodArgument : NSObject {
	@private
	NSString *_argumentName;
	NSArray *_argumentTypes;
	NSString *_argumentVar;
	NSArray *_terminationMacros;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased method argument with the given parameters.
 
 Internally this sends allocated instance `initWithName:types:var:variableArg:terminationMacros:` message, so check it's documentation for details.
 
 @param name The name of the method argument, part of method selector.
 @param types Array of argument types in the form of `NSString` instances or `nil` if not used.
 @param var Array of arguments in the form of `GBMethodArgument` instances or `nil` if not used.
 @param variableArg whether the last named parameter accepts indefinite number of arguments
 @param macros Array of termination macros
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 @see initWithName:types:var:variableArg:terminationMacros:
 */
+ (id)methodArgumentWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var variableArg:(BOOL)variableArg terminationMacros:(NSArray *)macros;

/** Returns autoreleased method argument with the given parameters.
 
 Internally this sends allocated instance `initWithName:types:var:variableArg:terminationMacros:` message, so check it's documentation for details.
 
 @param name The name of the method argument, part of method selector.
 @param types Array of argument types in the form of `NSString` instances or `nil` if not used.
 @param var Array of arguments in the form of `GBMethodArgument` instances or `nil` if not used.
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 @see initWithName:types:var:variableArg:terminationMacros:
 */
+ (id)methodArgumentWithName:(NSString *)name types:(NSArray *)types var:(NSString *)var;

/** Returns autoreleased type-less method argument.
 
 Internally this sends allocated instance `initWithName:types:var:variableArg:terminationMacros:` message, so check it's documentation for details.
 
 @param name The name of the method argument, part of method selector.
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if the argument is `nil` or empty string.
 @see initWithName:types:var:variableArg:terminationMacros:
 */
+ (id)methodArgumentWithName:(NSString *)name;

/** Initializes method argument with the given parameters.
 
 This is the designated initializer. You can either use it to specify method argument with all parameters, in such case you must supply all parameters, or you can use it to specify method argument without type. In such case you should set types and var to `nil`. If the argument is variable arg type, you should pass in optional termination macros or empty array if no termination macro is used. To specify standard argument, pass `nil` for termination macros instead!
 
 @warning *Note:* If you use the selector for type-less argument, both initializer parameters - types and var must be `nil`. If only one of these is `nil`, exception is thrown.
 
 @param argument The name of the method argument, part of method selector.
 @param types Array of argument types in the form of `NSString` instances or `nil` if not used.
 @param var Array of arguments in the form of `GBMethodArgument` instances or `nil` if not used.
 @param variableArg whether the last named parameter accepts indefinite number of arguments
 @param macros Array of termination macros
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 */
- (id)initWithName:(NSString *)argument types:(NSArray *)types var:(NSString *)var variableArg:(BOOL)variableArg terminationMacros:(NSArray *)macros;

///---------------------------------------------------------------------------------------
/// @name Argument data
///---------------------------------------------------------------------------------------

/** The name of the argument.
 
 Argument is part of method selector and defines -(result)*arg*:(type)var part of method.
 */
@property (readonly) NSString *argumentName;

/** Array of argument types.
 
 Types array define -(result)arg:(*type*)var part of method. If argument doesn't use types, this is empty array.
 */
@property (readonly) NSArray *argumentTypes;

/** The name of the argument variable.
 
 Argument variable defines -(result)arg:(type)*var* part of method. If argument doesn't use variable, this is `nil`.
 */
@property (copy) NSString *argumentVar;

/** Array of variable arguments termination macros.
 
 Termination macros array define -(result)arg:(type)var,...*macros* part of method. If argument isn't variable or doesn't have termination macros, this is `nil`.
 */
@property (readonly) NSArray *terminationMacros;

/** Specifies whether the argument is typed or not. The argument is typed if it uses type and var. */
@property (readonly) BOOL isTyped;

/** Specifies whether the argument is variable arg or not. */
@property (assign) BOOL isVariableArg;

@end
