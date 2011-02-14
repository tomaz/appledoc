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
/// @name Output generator helpers
///---------------------------------------------------------------------------------------

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
