//
//  GBComment.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBSourceInfo;
@class GBCommentParagraph;
@class GBCommentArgument;
@class GBParagraphLinkItem;

/** Handles all comment related stuff.
 
 Each instance describes a single source code comment for any object - class, category, protocol, method... As the comment is universal for each object, it contains properties for all fields applying to any kind of object. However not all are used in all cases. If a property is not used, it's value remains `nil`. Derived values are:
 
 - `paragraphs`: An array of `GBCommentParagraph` objects. The first entry is considered a short description, also available through `firstParagraph`.
 - `parameters`: An array of `GBCommentArgument` objects. Only applicable for methods with parameters.
 - `result`: A single `GBCommentArgument` object. Only applicable for methods with return value.
 - `exceptions`: An array of `GBCommentArgument` objects. Only applicable for methods with exceptions.
 - `crossrefs`: An array of `GBParagraphLinkItem` objects.
 
 All arrays must be provided in the desired order of output - i.e. output formatters don't apply any sorting, they simply emit the values in the given order.
 
 `GBComment` is not context aware by itself, it's simply a container object that holds comment information. It's the rest of the application that's responsible for setting it's values as needed. In most cases it's `GBParser`s who sets comments string value and `GBProcessor`s to parse string value and setup the derived properties based on the comment's context.
 
 @warning *Note:* Although derived values are prepared based on `stringValue`, nothing prevents clients to setup derived values directly, "on the fly" if needed. However splitting the interface allows us to simplify parsing code and allow us to handle derives values when we have complete information available.
 */
@interface GBComment : NSObject {
	@private
	NSMutableArray *_paragraphs;
	NSMutableArray *_descriptionParagraphs;
	NSMutableArray *_parameters;
	NSMutableArray *_exceptions;
	NSMutableArray *_crossrefs;
}

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
/// @name Paragraphs handling
///---------------------------------------------------------------------------------------

/** Registers the `GBCommentParagraph` and adds it to the end of `paragraphs` array.
 
 If `paragraphs` is `nil`, a new array is created before adding the given object to it and the given paragraph is assigned as `firstParagraph` (the object is also added to `paragraphs` array!).
 
 @param paragraph Paragraph to register.
 @exception NSException Thrown if the given paragraph is `nil`.
 @see firstParagraph
 @see paragraphs
 */
- (void)registerParagraph:(GBCommentParagraph *)paragraph;

/** The first paragraph from `paragraphs` list or `nil` if no paragraph is registered.
 
 The value is automatically set when registering paragraphs, although it can be changed if needed. By default the value is set to the first paragraph registered.
 
 @see registerParagraph:
 @see paragraphs
 @see descriptionParagraphs
 */
@property (retain) GBCommentParagraph *firstParagraph;

/** `NSArray` containing all paragraphs of the comment.
 
 The paragraphs are in same order as in the source code. First paragraph is used for short description and is also available via `firstParagraph`. Each object is a `GBCommentParagraph` instance and should be registered through `registerParagraph:` method.

 @see firstParagraph
 @see descriptionParagraphs
 @see registerParagraph:
 @see parameters
 @see exceptions
 @see result
 */
@property (readonly) NSArray *paragraphs;

///---------------------------------------------------------------------------------------
/// @name Description paragraphs handling
///---------------------------------------------------------------------------------------

/** Registers the `GBCommentParagraph` and adds it to the end of `descriptionParagraphs` array.
 
 If `descriptionParagraphs` is `nil`, a new array is created before adding the given object to it.
 
 @param paragraph Paragraph to register.
 @exception NSException Thrown if the given paragraph is `nil`.
 @see descriptionParagraphs
 @see registerParagraph:
 */
- (void)registerDescriptionParagraph:(GBCommentParagraph *)paragraph;

/** `NSArray` containing all paragraphs that should be used for object description.
 
 The paragraphs are in the same order as in the source code. Each object is a `GBCommentParagraph` instance and should be registered through `registerDescriptionParagraph:` method. This array may be the same as `paragraphs` or it may be different, depending the application settings. It's up to client code to provide the description paragraphs!
 
 @see paragraphs
 @see hasDescriptionParagraphs
 @see registerDescriptionParagraph:
 */
@property (readonly) NSArray *descriptionParagraphs;

///---------------------------------------------------------------------------------------
/// @name Method arguments handling
///---------------------------------------------------------------------------------------

/** Registers the `GBCommentArgument` that describes a parameter and adds it to the end of `parameters` array.
 
 If `parameters` is `nil`, a new array is created before adding the given object to it. If a parameter with the same name is already registered, a warning is logged and previous item is replaced with the given one.
 
 @param parameter Parameter to register.
 @exception NSException Thrown if the given parameter is `nil` or `[GBCommentArgument argumentName]` is `nil` or empty string.
 @see parameters
 @see replaceParametersWithParametersFromArray:
 @see registerResult:
 @see registerException:
 @see registerCrossReference:
 */
- (void)registerParameter:(GBCommentArgument *)parameter;

/** Replaces all registered `parameters` with the objects from the given array.
 
 The given array should only contain `GBCommentArgument` objects. If there are any parameters registered, they will be removed first! If `nil` or empty array is passed, current parameters are removed only.
 
 @param array The array of parameters to register.
 @exception NSException Thrown if any of the objects is invalid, see registerParameter: for details.
 */
- (void)replaceParametersWithParametersFromArray:(NSArray *)array;

/** Registers the `GBCommentParagraph` that describes method return value.
 
 If a result is already registered, a warning is logged and previous result is replaced with the given one.
 
 @param result Result to register.
 @exception NSException Thrown if the given result is `nil`.
 @see result
 @see registerParameter:
 @see registerException:
 @see registerCrossReference:
 */
- (void)registerResult:(GBCommentParagraph *)result;

/** Registers the `GBCommentArgument` that describes an exception the method can raise and adds it to the end of `exceptions` array.
 
 If `exceptions` is `nil`, a new array is created before adding the given object to it. If an exception with the same name is already registered, a warning is logged and previous item is replaced with the given one.
 
 @param exception Exception to register.
 @exception NSException Thrown if the given exception is `nil`.
 @see exceptions
 @see registerParameter:
 @see registerResult:
 @see registerCrossReference:
 */
- (void)registerException:(GBCommentArgument *)exception;

/** Registers the `GBParagraphLinkItem` as an explicit, comment-wide, cross reference and adds it to the end of `crossrefs` array.
 
 If `crossrefs` is `nil`, a new array is created before adding the given object to it. If a reference to the same object is already registered, a warning is logged and nothing happens.
 
 @param ref The cross reference to register.
 @see crossrefs
 @see registerParameter:
 @see registerResult:
 @see registerException:
 @exception NSException Thrown if the given reference is `nil`.
 */
- (void)registerCrossReference:(GBParagraphLinkItem *)ref;

/** `NSArray` containing all method parameters described within the comment.
 
 Parameters are in the order of declaration within code regardless of the order declared in the comment! Each object is a `GBCommentArgument` instance and should be registered through `registerParameter:` method.
 
 @see registerParameter:
 @see exceptions
 @see result
 @see crossrefs
 @see paragraphs
 */
@property (readonly) NSArray *parameters;

/** The description of the method result or `nil` if this is not method comment or method has no result.
 
 The description is a `GBCommentParagraph` instance and should be `registerResult:` to register the result.
 
 @see registerResult:
 @see parameters
 @see exceptions
 @see crossrefs
 @see paragraphs
 */
@property (readonly,retain) GBCommentParagraph *result;

/** `NSArray` containing all exceptions commented method can raise as described within the comment.
 
 Exceptions are in the order of declaration in the comment. Each object is a `GBCommentArgument` instance and should be registered through `registerException:` method.
 
 @see registerException:
 @see parameters
 @see result
 @see crossrefs
 @see paragraphs
 */
@property (readonly) NSArray *exceptions;

/** `NSArray` containing all explicit cross references as described within the comment.
 
 Cross references can point to an URL, local member, another object or remote member. They are listed in the order as declared in the comment. Each object is a `GBParagraphLinkItem` instance and should be registered through `registerCrossReference:` method.
 
 @see registerCrossReference:
 @see parameters
 @see result
 @see exceptions
 @see paragraphs
 */
@property (readonly) NSArray *crossrefs;

///---------------------------------------------------------------------------------------
/// @name Output generator helpers
///---------------------------------------------------------------------------------------

/** Indicates whether the comment has at least one paragraph or not.
 
 This is used mainly to simplify template output generators. Programmatically this method is equal to testing whether `paragraphs` count is greater than 0, like this: `[object.paragraphs count] > 0`.
 
 @see hasDescriptionParagraphs
 @see paragraphs
 */
@property (readonly) BOOL hasParagraphs;

/** Indicates whether the comment has at least two paragraphs or not.
 
 This is used mainly to simplify template output generators. Programmatically this method is equal to testing whether `descriptionParagraphs` count is greater than 0, like this: `[object.descriptionParagraphs count] > 0`.
 
 @see hasParagraphs
 @see paragraphs
 */
@property (readonly) BOOL hasDescriptionParagraphs;

/** Indicates whether the comment has at least one parameter or not.
 
 This is used mainly to simplify template output generators. Programmatically this method is equal to testing whether `parameters` count is greater than 0, like this: `[object.parameters count] > 0`.
 
 @see parameters
 */
@property (readonly) BOOL hasParameters;

/** Indicates whether the comment has at least one exception or not.
 
 This is used mainly to simplify template output generators. Programmatically this method is equal to testing whether `exceptions` count is greater than 0, like this: `[object.exceptions count] > 0`.
 
 @see exceptions
 */
@property (readonly) BOOL hasExceptions;

/** Indicates whether the comment has at least one cross reference or not.
 
 This is used mainly to simplify template output generators. Programmatically this method is equal to testing whether `crossrefs` count is greater than 0, like this: `[object.crossrefs count] > 0`.
 
 @see exceptions
 */
@property (readonly) BOOL hasCrossrefs;

/** Specifies whether the comment is copied from another object or this is the original comment from source code.
 
 This flag is used to ignore unknown cross references warnings for comments copied from another object.
 */
@property (assign) BOOL isCopied;

///---------------------------------------------------------------------------------------
/// @name Input values
///---------------------------------------------------------------------------------------

/** Comment's source file info. */
@property (retain) GBSourceInfo *sourceInfo;

/** Comment's raw string value as declared in source code. */
@property (copy) NSString *stringValue;

@end
