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
 
 @warning *Important:* In order to get proper value of `htmlValue`, `GBApplicationSettingsProvider` instance must be assigned to `settings` before using `htmlValue`! This is handled during processing phase automatically at the time of creation of the component, so it works seamlesly. It's good to be aware of this fact though as it may lead to surprises later on.
 */
@interface GBCommentComponent : NSObject {
	@private
	NSString *_htmlValue;
	NSString *_textValue;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased instance of the comment with the given string value.
 
 This is a helper initializer which allows setting string value with a single message. Sending this message is equivalent to sending `commentWithStringValue:sourceInfo:`, passing the given _value_ and `nil` for source info.
 
 @param value String value to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see componentWithStringValue:sourceInfo:
 */
+ (id)componentWithStringValue:(NSString *)value;

/** Returns a new autoreleased instance of the comment with the given string value and source info.
 
 This is a helper initializer which allows setting default values with a single message.
 
 @param value String value to set.
 @param info Source info to set.
 @return Returns initialized object or `nil` if initialization fails.
 @see componentWithStringValue:
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
 
 This value is derived when first used, the value is cached afterwards and cached value is returned from subsequent calls. Internally [GBApplicationSettingsProvider stringByConvertingMarkdownToHTML:] is used for conversion.
 
 @warning *Important:* This value requires `settings` to be assigned! If settings are not assigned, the value or `markdownValue` is returned but is not cached, so that any subsequent assigning of settings would pick up proper html.
 
 @see textValue
 */
@property (readonly) NSString *htmlValue;

/** Component's text value, derived by passing assigned `markdownValue` through text processor.
 
 The result is suitable for using in documentation set tokens file. Using converted HTML may result in errors when indexing due to usage of escaped HTML symbols (for example any `&ndash;` would result in docsetutil error `Entity 'ndash' not defined`. This value is derived when first used, the value is cached afterwards and cached value is returned from subsequent calls. Internally [GBApplicationSettingsProvider stringByConvertingMarkdownToText:] is used for conversion.
 
 @warning *Important:* This value requires `settings` to be assigned! If settings are not assigned, the value of `markdownValue` is returned but is not cached, so that any subsequent assigning of settings would pick up proper text.
 
 @see htmlValue
 */
@property (readonly) NSString *textValue;

/** Source file information.
 */
@property (strong) GBSourceInfo *sourceInfo;

///---------------------------------------------------------------------------------------
/// @name Helper attributes
///---------------------------------------------------------------------------------------

/** This is used only for related items to allow creating documentation set identifiers.
 */
@property (strong) id relatedItem;

/** Settings used for creating various values.
 */
@property (strong) id settings;

@end
