//
//  GBParagraphListItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 31.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"

/** Handles ordered and unordered lists for a `GBCommentParagraph`.
 
 Lists are containers for list items which are instances of `GBCommentParagraph`. This allows us to form a tree structure with nested lists and other paragraph items.
 */
@interface GBParagraphListItem : GBParagraphItem {
	@private
	NSMutableArray *_items;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns new autoreleased list item with `ordered` set to `YES`.
 
 This is equivalent to initializing with designated initialized (`init`) and setting `ordered` property value of initializaed object to `YES`.
 */
+ (id)orderedParagraphListItem;

/** Returns new autoreleased list item with `ordered` set to `NO`.
 
 This is equivalent to initializing with designated initialized (`init`) and setting `ordered` property value of initializaed object to `NO`.
 */
+ (id)unorderedParagraphListItem;

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** Registers the given item by adding it to the end of `items` array.
 
 @param item `GBCommentParagraph` to register.
 @exception NSException Thrown if the given item is `nil`.
 */
- (void)registerItem:(GBCommentParagraph *)item;

/** Specifies whether the list is ordered (`YES`) or unordered (`NO`). */
@property (assign) BOOL ordered;

/** Array of all list items as instances of `GBCommentParagraph` in the same order as in comment text. */
@property (readonly) NSArray *items;

@end
