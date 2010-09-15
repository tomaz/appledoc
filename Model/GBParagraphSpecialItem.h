//
//  GBParagraphSpecialItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 1.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"

@class GBCommentParagraph;

/** Defines different `GBParagraphSpecialItem` types. */
enum {
	/** The `GBParagraphSpecialItem` represents a warning. */
	GBSpecialItemTypeWarning,
	/** The `GBParagraphSpecialItem` represents a bug. */
	GBSpecialItemTypeBug,
	/** The `GBParagraphSpecialItem` represents an example section. */
	GBSpecialItemTypeExample,
};
typedef NSUInteger GBSpecialItemType;

#pragma mark -

/** Handles special paragraph items such as warnings and bugs.
 
 Special items are containers for `GBCommentParagraph` which are formatted differently to catch user's attention. There can be several types of special items, to determine the type, use the value of `specialItemType` property.
 */
@interface GBParagraphSpecialItem : GBParagraphItem {
	@private
	GBCommentParagraph *_specialItemDescription;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns new autoreleased `GBParagraphSpecialItem` instance of te given type.
 
 Sending this message to the class is equivalent of:
 
	GBParagraphSpecialItem *item = [[[GBParagraphSpecialItem alloc] init] autorelease];
	item.specialItemType = type;
 
 @param type The type of the special item.
 @return Returns initialized instance.
 @see specialItemWithType:stringValue:
 */
+ (id)specialItemWithType:(GBSpecialItemType)type;

/** Returns new autoreleased `GBParagraphSpecialItem` instance of te given type.
 
 Sending this message to the class is equivalent of:
 
	GBParagraphSpecialItem *item = [[[GBParagraphSpecialItem alloc] init] autorelease];
	item.specialItemType = type;
	item.stringValue = value;
 
 @param type The type of the special item.
 @param value The desired string value.
 @return Returns initialized instance.
 @see specialItemWithType:
 */
+ (id)specialItemWithType:(GBSpecialItemType)type stringValue:(NSString *)value;

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** Registers the given paragraph.
 
 @param paragraph `GBCommentParagraph` to register.
 @exception NSException Thrown if the given item is `nil`.
 */
- (void)registerParagraph:(GBCommentParagraph *)paragraph;

/** The description of the special item in the form of `GBCommentParagraph`. */
@property (readonly) GBCommentParagraph *specialItemDescription;

/** The type of the special item. */
@property (assign) GBSpecialItemType specialItemType;

@end
