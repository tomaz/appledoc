//
//  GBComment.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBSourceInfo;
@class GBCommentComponent;
@class GBCommentComponentsList;

/** Handles all comment related stuff.
 
 Each instance describes a single source code comment for any object - class, category, protocol, method... As the comment is universal for each object, it contains properties for all fields applying to any kind of object. However not all are used in all cases. If a property is not used, it's value remains `nil`. Derived values are handled with:
 
 - `shortDescription`: Provides short description of the commented entity used for tooltips and abstract.
 - `longDescription`: Provides the whole description of the commented entity. This can include `shortDescription` or not, based on settings.
 - `methodParameters`: The list of all method parameters. Only used for methods.
 - `methodResult`: Description of method result. Only used for methods.
 - `methodExceptions`: The list of all possible exceptions. Only used for methods.
 - `availability`: A text representing the version at which this method / property is available. Can also be applied to other entities
 - `relatedItems`: The list of all related items. Used for cross referencing other entities.
 
 All lists must be provided in the desired order of output - i.e. output formatters don't apply any sorting, they simply emit the values in the given order.
 
 `GBComment` is not context aware by itself, it's simply a container object that holds comment information. It's the rest of the application that's responsible for setting it's values as needed. In most cases it's `GBParser`s who sets comments string value and `GBProcessor`s to parse string value and setup the derived properties based on the comment's context.
 
 @warning *Note:* Although derived values are prepared based on `stringValue`, nothing prevents clients to setup derived values directly, "on the fly" if needed. However splitting the interface allows us to simplify parsing code and allow us to handle derives values when we have complete information available.
 */
@interface GBComment : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased instance of the comment with the given string value.
 
 This is a helper initializer which allows setting string value with a single message. Sending this message is equivalent to sending `commentWithStringValue:sourceInfo:`, passing the given _value_ and `nil` for source info.
 
 @param value String value to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see commentWithStringValue:sourceInfo:
 */
+ (id)commentWithStringValue:(NSString *)value;

/** Returns a new autoreleased instance of the comment with the given string value and source info.
 
 This is a helper initializer which allows setting default values with a single message.
 
 @param value String value to set.
 @param info Source info to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see commentWithStringValue:
 */
+ (id)commentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info;

///---------------------------------------------------------------------------------------
/// @name Comment components handling
///---------------------------------------------------------------------------------------

/** Comments short description used for tooltips and abstract in the form of `GBCommentComponent`.
 
 @see longDescription
 */
@property (strong) GBCommentComponent *shortDescription;

/** Comments long description, includes the whole description components.
 
 Depending settings, this may also repeat `shortDescription` or not. `GBComment` assigns default object here, but clients are free to replace it with their own implementations.
 
 @see shortDescription
 */
@property (strong) GBCommentComponentsList *longDescription;

/** The list to related items.
 
 This is simply a list of `GBCommentComponent`s, each one containing a cross reference to a single item.
 */
@property (strong) GBCommentComponentsList *relatedItems;

/** All registered method parameters, only applicable for methods, empty list is used otherwise.
 
 This is a list of `GBCommentArgument` objects.
 
 @see methodExceptions
 @see methodResult
 */
@property (strong) NSMutableArray *methodParameters;

/** All registeres method exceptions, only applicable for methods, empty list if used otherwise.
 
 This is a list of `GBCommentArgument` objects.
 
 @see methodParameters
 @see methodResult
 */
@property (strong) NSMutableArray *methodExceptions;

/** Method result description, only applicable for methods, empty list is used otherwise.
 
 @see methodParameters
 @see methodExceptions
 */
@property (strong) GBCommentComponentsList *methodResult;

/** Entity availability description.

 */
@property (strong) GBCommentComponentsList *availability;

///---------------------------------------------------------------------------------------
/// @name Output generator helpers
///---------------------------------------------------------------------------------------

/** Specifies the original processing context of the comment.
 
 This value points to the context inside which the comment was parsed. The main reason for this is to restrict processing of copied comments within their original context, so that any cross references are properly handled(mainly to suppress unrelated warnings). The value related to the context is:
 
 - Normal comments attached to classes, categories, protocols or methods as found in source code: the value is `nil`.
 - Comments assigned to classes, categories or protocols, copied from another class, category or protocol: the value is the pointer to the original object.
 - Comments assigned to methods, copied from another method: the value is the pointer to original method's parent.
 
 @see isCopied
 */
@property (unsafe_unretained) id originalContext;

/** Specifies whether the comment is copied from another object or this is the original comment from source code.

 The value of this property depends on `originalContext`. If original context is assigned, the value is `YES`, otherwise it's `NO`.
 
 @see originalContext
 @see isProcessed
 */
@property (readonly) BOOL isCopied;

/** Specifies whether the comment is already processed or not.
 
 This is used mainly for better support of copied comments!
 
 @see isCopied
 */
@property (assign) BOOL isProcessed;

/** Specifies whether the comment has short description or not.
 
 @see hasLongDescription
 */
@property (readonly) BOOL hasShortDescription;

/** Specifies whether the comment has long description or not.
 
 @see hasShortDescription
 */
@property (readonly) BOOL hasLongDescription;

/** Specifies whether the `methodParameters` contains at least one object or not.
 
 @see hasMethodExceptions
 @see hasMethodResult
 */
@property (readonly) BOOL hasMethodParameters;

/** Specifies whether the `methodExceptions` contains at least one object or not.
 
 @see hasMethodParameters
 @see hasMethodResult
 */
@property (readonly) BOOL hasMethodExceptions;

/** Specifies whether the `methodResult` contains at least one object or not.
 
 @see hasMethodParameters
 @see hasMethodExceptions
 */
@property (readonly) BOOL hasMethodResult;

/** Specifies whether the `availability` contains at least one object or not.
 
 @see availability
 */
@property (readonly) BOOL hasAvailability;

/** Specifies whether the `relatedItems` contains at least one object or not.
 */
@property (readonly) BOOL hasRelatedItems;

///---------------------------------------------------------------------------------------
/// @name Input values
///---------------------------------------------------------------------------------------

/** Comment's source file info. */
@property (strong) GBSourceInfo *sourceInfo;

/** Comment's raw string value as declared in source code. */
@property (copy) NSString *stringValue;

@end
