//
//  GBParagraphDecoratorItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 2.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBParagraphItem.h"

/** Specifies different decoration types of `GBParagraphDecoratorItem`s. */
enum {
	/** The `GBParagraphDecoratorItem`s decorated item should be bold. */
	GBDecorationTypeBold,
	/** The `GBParagraphDecoratorItem`s decorated item should be italics. */
	GBDecorationTypeItalics,
	/** The `GBParagraphDecoratorItem`s decorated item should be code. */
	GBDecorationTypeCode,
};
typedef NSUInteger GBDecorationType;

#pragma mark -

/** Specifies a decorator paragraph item.
 
 Decorator items wrap an array of `GBParagraphItem` and speficies a decoration to be applied over them. Use `decorationType` to determine the type of decoration and `decoratedItems` to get the array of item to be decorated.
 */
@interface GBParagraphDecoratorItem : GBParagraphItem {
	@private
	NSMutableArray *_decoratedItems;
}

/** Registers the given item to the end of `decoratedItems` array.
 
 @param item The item to register.
 @exception NSException Thrown if the given item is `nil`.
 @see replaceItemsByRegisteringItemsFromArray:
 */
- (void)registerItem:(GBParagraphItem *)item;

/** Replaces the `decoratedItems` array with the objects from the given array.
 
 @param items The array of `GBParagraphItem` instances to register.
 @see registerItem:
 */
- (void)replaceItemsByRegisteringItemsFromArray:(NSArray *)items;

/** The type of decoration to apply over assigned `decoratedItems`. */
@property (assign) GBDecorationType decorationType;

/** The `GBParagraphItem` instances we're decorating.
 
 Items can be registered through `registerItem:` or `registerItems:` methods.
 
 @see registerItem:
 @see replaceItemsByRegisteringItemsFromArray:
 */
@property (readonly) NSArray *decoratedItems;

@end
