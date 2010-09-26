//
//  GBMethodData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@class GBMethodArgument;


/** Defines different method types. */
enum {
	GBMethodTypeClass,		//< Method data describes a class method.
	GBMethodTypeInstance,	//< Method data describes an instance method.
	GBMethodTypeProperty	//< Method data describes a property.
};
typedef NSUInteger GBMethodType;

#pragma mark -

/** Describes a method or property.
 
 Each instance or class method or property description contains at least one argument in the form of `GBMethodArgument` instance. Note that arguments should not be confused with method parameters, although they are very similar. In objective-c each method has a selector with optional parameter, followed by more parameters if applicable, with each parameter's selector delimited with a colon. appledoc on the other hand groups even the first part of the selector as an argument, however if the method doesn't have parameters, the argument's type and variable remain `nil`. This is how you can easily distinguish between different methods and properties:
 
 - Method without parameters: `methodArguments` array contains a single object with `[GBMethodArgument argumentName]` value assigned as method name and both, `[GBMethodArgument argumentTypes]` and `[GBMethodArgument argumentVar]` set to `nil`. Result is optional. Example: `- (void)method;`.
 - Method with single parameter: `methodArguments` array contains a single object with `[GBMethodArgument argumentName]` value assigned as method name, `[GBMethodArgument argumentTypes]` contains an array with at least one object describing the type of the parameter and `[GBMethodArgument argumentVar]` describing the name of the parameter variable. Result is optional. Example: `- (void)method:(NSString *)var;`, where argument types would contain _NSString_ and _*_ strings and argument variable _var_.
 - Method with multiple parameters: `methodArguments` array contains at least two objects, each describing it's parameter. First instance describes the base method selector name including first parameter type and variable name. Result is optional. Example `- (void)method:(NSUInteger)var1 withValue:(id)var2`, where first argument would have name _method_, types _NSUInteger_ and variable name _var1_ and second argument _withValue_, _id_ and _var2_.
 - Properties have the same signature as methods without parameters but always have at least one result object.
 */
@interface GBMethodData : GBModelBase {
	@private
	GBMethodType _methodType;
	NSArray *_methodAttributes;
	NSArray *_methodResultTypes;
	NSArray *_methodArguments;
	NSString *_methodSelector;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased method data with the given parameters.
 
 @param type The type of method defined by `GBMethodType` enumeration.
 @param result Array of resulting types in the form of `NSString` instances.
 @param arguments Array of arguments in the form of `GBMethodArgument` instances.
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 */
+ (id)methodDataWithType:(GBMethodType)type result:(NSArray *)result arguments:(NSArray *)arguments;


/** Returns autoreleased property data with the given parameters.
 
 @param type The type of method defined by `GBMethodType` enumeration.
 @param components Array of resulting types with last item as property name in the form of `NSString` instances.
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 */
+ (id)propertyDataWithAttributes:(NSArray *)attributes components:(NSArray *)components;

/** Initializes method data with the given parameters.
 
 This is the designated initializer.
 
 @param type The type of method defined by `GBMethodType` enumeration.
 @param attributes Array of property attributes or `nil` if this is method. 
 @param result Array of resulting types in the form of `NSString` instances.
 @param arguments Array of arguments in the form of `GBMethodArgument` instances.
 @return Returns initialized object or `nil` if initialization fails.
 @exception NSException Thrown if either of the given parameters is invalid.
 */
- (id)initWithType:(GBMethodType)type attributes:(NSArray *)attributes result:(NSArray *)result arguments:(NSArray *)arguments;

///---------------------------------------------------------------------------------------
/// @name Method data
///---------------------------------------------------------------------------------------

/** The type of method with possible values defined by `GBMethodType` enumeration. */
@property (readonly) GBMethodType methodType;

/** Array of property attributes represented with `NSString` instances.
 
 This only applies when `methodType` is `GBMethodTypeProperty`, the value is `nil` otherwise!
 */
@property (readonly) NSArray *methodAttributes;

/** Array of method result type components represented with `NSString` instances. */
@property (readonly) NSArray *methodResultTypes;

/** Array of method arguments represented with `GBMethodArgument` instances with at least one object. */
@property (readonly) NSArray *methodArguments;

/** Method selector that can be used for unique identification. */
@property (readonly) NSString *methodSelector;

@end
