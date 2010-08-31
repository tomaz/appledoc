//
//  GBCommentParagraph.h
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBParagraphItem;

/** Describes a paragraph for a `GBComment`.
 
 A paragraph is simply an array of items. It can contain the following objects: `GBParagraphTextItem`, `GBParagraphListItem`, `GBParagraphFormattedTextItem`, `GBParagraphLinkItem`, `GBParagraphExampleItem`.
 */
@interface GBCommentParagraph : NSObject {
	@private
	NSMutableArray *_items;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased paragraph instance. */
+ (id)paragraph;

///---------------------------------------------------------------------------------------
/// @name Paragraph values
///---------------------------------------------------------------------------------------

/** Registers the given paragraph item by adding it to the end of `items` list.
 
 @param item The item to register.
 @exception NSException Thrown if `nil` is passed.
 */
- (void)registerItem:(GBParagraphItem *)item;

/** The list of all paragraph items in the order of registration. 
 
 Each object is a subclass of `GBParagraphItem`.
 */
@property (readonly) NSArray *items;

///---------------------------------------------------------------------------------------
/// @name Input values
///---------------------------------------------------------------------------------------

/** Paragraph's raw string value as declared in source code. */
@property (readonly) NSString *stringValue;

@end
