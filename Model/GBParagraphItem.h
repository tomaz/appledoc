//
//  GBParagraphItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Defines the base functionality for all paragraph items. 
 */
@interface GBParagraphItem : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns new autoreleased instance. */
+ (id)paragraphItem;

/** Returns new autoreleased instance with `stringValue` set to the given text.
 
 This is equivalent to the following code:
 
	GBParagraphItem *item = [GBParagraphItem paragraphItem];
	item.stringValue = value;
 
 @param value The string value of the item.
 @return Returns initialized value.
 */
+ (id)paragraphItemWithStringValue:(NSString *)value;

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** Item's string value.
 
 String value is used for output generation in case of leaf items. For container items, string value should not be used for output generation unless specified otherwise!
 */
@property (copy) NSString *stringValue;

///---------------------------------------------------------------------------------------
/// @name Debugging aids
///---------------------------------------------------------------------------------------

/** String value as used in debug description.
 
 By default this returns string value trimmed to a predefined maximum length, but subclasses can override to provide their specific implementation. This is only used for debugging purposes and should not be used for any output generation! See `description` method implementation for details.
 
 Sending this message is equivalent to sending `descriptionForStringValue:` to receiver and passing it `stringValue` as the parameter.
 
 @see descriptionStringValueFromValue:
 */
@property (readonly) NSString *descriptionStringValue;

///---------------------------------------------------------------------------------------
/// @name Output generator helpers
///---------------------------------------------------------------------------------------

/** Returns `YES` if this item is text. This is only used to simplify output generation! */
@property (readonly) BOOL isTextItem;

/** Returns `YES` if this is ordered list item. This is only used to simplify output generation! */
@property (readonly) BOOL isOrderedListItem;

/** Returns `YES` if this is unordered list item. This is only used to simplify output generation! */
@property (readonly) BOOL isUnorderedListItem;

/** Returns `YES` if this is warning special item. This is only used to simplify output generation! */
@property (readonly) BOOL isWarningSpecialItem;

/** Returns `YES` if this is bug special item. This is only used to simplify output generation! */
@property (readonly) BOOL isBugSpecialItem;

/** Returns `YES` if this is example special item. This is only used to simplify output generation! */
@property (readonly) BOOL isExampleSpecialItem;

/** Returns `YES` if this is bold decorator item. This is only used to simplify output generation! */
@property (readonly) BOOL isBoldDecoratorItem;

/** Returns `YES` if this is italics decorator item. This is only used to simplify output generation! */
@property (readonly) BOOL isItalicsDecoratorItem;

/** Returns `YES` if this is code decorator item. This is only used to simplify output generation! */
@property (readonly) BOOL isCodeDecoratorItem;

/** Returns `YES` if this is link item. This is only used to simplify output generation! */
@property (readonly) BOOL isLinkItem;

@end
