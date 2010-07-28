//
//  GBMethodData.h
//  appledoc
//
//  Created by Tomaz Kragelj on 26.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBModelBase.h"
#import "GBMethodArgument.h"

/** Defines different method types. */
enum {
	GBMethodTypeClass,		//< Method data describes a class method.
	GBMethodTypeInstance,	//< Method data describes an instance method.
	GBMethodTypeProperty	//< Method data describes a property.
};
typedef NSUInteger GBMethodType;

#pragma mark -

/** Describes a method or property. */
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
