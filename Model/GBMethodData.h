//
//  GBMethodData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"

@class GBMethodArgument;
@class GBMethodSectionData;

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
 
 To aid output templates handling, the method also prepares formatted components that can be used directly within output templates. Formatted components include all whitespace as needed to match desired coding style, so output generators can simply write the given formatted values. Although it could be argued that this should be rather part of output template, the ammount and complexity of template directives would be much greater than doing this in code. As additional bonus, we can have formatting code under unit tests to quickly verify it works as needed. And templates that really need to hande specifics, can still do so... See `formattedComponents` for details.
 */
@interface GBMethodData : GBModelBase {
	@private
	GBMethodType _methodType;
	NSArray *_methodAttributes;
	NSArray *_methodResultTypes;
	NSArray *_methodArguments;
	NSString *_methodSelector;
	NSString *_prefixedMethodSelector;
	NSString *_methodSelectorDelimiter;
	NSString *_methodPrefix;
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
 
 @param attributes Array of property attributes in the form of `NSString` instances.
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
 
 This only applies when `methodType` is `GBMethodTypeProperty`, the value is an empty array otherwise!
 */
@property (readonly) NSArray *methodAttributes;

/** Array of method result type components represented with `NSString` instances. */
@property (readonly) NSArray *methodResultTypes;

/** Array of method arguments represented with `GBMethodArgument` instances with at least one object. */
@property (readonly) NSArray *methodArguments;

/** Method selector that can be used for unique identification. 
 
 The selector doesn't include prefix, if you need to include that, use the value of `prefixedMethodPrefix`.
 
 @see prefixedMethodSelector
 */
@property (readonly) NSString *methodSelector;

/** Method return type that can be used for shared property/method names. */
@property (readonly) NSString *methodReturnType;

/** Method selector including prefix.
 
 @see methodSelector
 */
@property (readonly) NSString *prefixedMethodSelector;

/** The section this method belongs to.
 
 Primarily used so that we can setup proper section name when merging from protocols.
 */
@property (strong) GBMethodSectionData *methodSection;

/** A string representing the type of the method
 */
@property (readonly) NSString *methodTypeString;

///---------------------------------------------------------------------------------------
/// @name Helper properties
///---------------------------------------------------------------------------------------

/** Specified whether this method is an instance method or not.
 
 This is convenience accessor for simpler template handling. Internally it's equivalent to `methodType == GBMethodTypeInstance`.
 */
@property (readonly) BOOL isInstanceMethod;

/** Specifies whether this method is a class method or not.
 
 This is convenience accessor for simpler template handling. Internally it's equivalent to `methodType == GBMethodTypeClass`.
 */
@property (readonly) BOOL isClassMethod;

/** Specifies whether this method is a class or instance method or not.
 
 This is convenience accessor for simpler template handling. Internally it's equivalent to `methodType != GBMethodTypeProperty`.
 */
@property (readonly) BOOL isMethod;

/** Specifies whether this method is a property or not.
 
 This is convenience accessor for simpler template handling. Internally it's equivalent to `methodType == GBMethodTypeProperty`.
 */
@property (readonly) BOOL isProperty;

/** Specifies whether the method is required or not.
 
 This is only used for protocols where certain methods can be marked as optional and certain as required. Default value is `NO`.
 */
@property (assign) BOOL isRequired;

///---------------------------------------------------------------------------------------
/// @name Helper methods
///---------------------------------------------------------------------------------------

/** Returns the selector name of the getter for the property.
 
 This searches the `methodAttributes` array for custom getter and returns that value if found. Otherwise it returns default getter. This only applies to properties, returns `nil` otherwise!
 
 @see propertySetterSelector
 */
- (NSString *)propertyGetterSelector;

/** Returns the selector name of the setter for the property.
 
 This searches the `methodAttributes` array for custom setter and returns that value if found. Otherwise it returns default setter. This only applies to properties, returns `nil` otherwise!
 
 @see propertyGetterSelector
 */
- (NSString *)propertySetterSelector;

/** Returns the array of formatted components optimized for output generation.
 
 This is more or less implemented here for simpler output generator templates. Instead of programming all the conditionals in cumbersome template language, we do it in simple objective-c code, which can even be unit tested.
 
 The result is an array of components containing `NSDictionary` instances with the following keys:
 
 - `value`: a `NSString` containing the actual value to be output. This value is always present and is neven empty string.
 - `style`: a `NSNumber` containing desired style. At this point, the only possible value is `1` for emphasized. If normal style is desired, this key is not present in the dictionary.
 - `emphasized`: a `GRYes` indicating whether the `style` is `1`. If style is not `1`, this key is missing.
 - `href`: a `NSString` containing the HTML cross reference link that should be applied with the component. If no cross reference is attached, the key is not present in the dictionary.
 
 @return Returns formatted components of the receiver.
 */
- (NSArray *)formattedComponents;

/** Returns the data type of the property.

 This searches the `methodResultTypes` array and returns the property data type. This only applies to properties, returns `nil` otherwise!

 @see methodResultTypes
 */
- (NSString *)propertyType;

@end
