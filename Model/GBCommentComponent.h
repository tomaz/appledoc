//
//  GBCommentComponent.h
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBSourceInfo;

/** Handles individual `GBComment` component.
 
 A comment component is basic building block for `GBComment`s. It's primary responsibility is storing representation suitable for Markdown processor. The reason for splitting comment text into components is to allow support for various output styles, such as `@warning` and `@bug`. These require slightly different preprocessing. This object is lightweight, it doesn't do any processing, just provides properties that hold the data, it's the job of higher level components to setup the data properly.
 */
@interface GBCommentComponent : NSObject {
	@private
	NSString *_htmlValue;
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
+ (id)componentWithStringValue:(NSString *)value;

/** Returns a new autoreleased instance of the comment with the given string value and source info.
 
 This is a helper initializer which allows setting default values with a single message.
 
 @param value String value to set.
 @param info Source info to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see commentWithStringValue:
 */
+ (id)componentWithStringValue:(NSString *)value sourceInfo:(GBSourceInfo *)info;

///---------------------------------------------------------------------------------------
/// @name Component data
///---------------------------------------------------------------------------------------

/** Component's string value from the source code.
 */
@property (copy) NSString *stringValue;

/** Component's markdown value, derived from `stringValue`.
 */
@property (copy) NSString *markdownValue;

/** Component's HTML value, derived by passing assigned `markdownValue` through Markdown processor.
 
 This value is derived when first used, the value is cached afterwards and cached value is returned from subsequent calls.
 */
@property (readonly) NSString *htmlValue;

/** Source file information.
 */
@property (retain) GBSourceInfo *sourceInfo;

@end
