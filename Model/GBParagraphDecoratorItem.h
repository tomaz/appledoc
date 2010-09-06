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
 
 Decorator items wrap a `GBParagraphItem` and speficy a decoration to be applied over the item. Use `decorationType` to determine the type of decoration and `decoratedItem` to get the item to be decorated.
 */
@interface GBParagraphDecoratorItem : GBParagraphItem

/** The type of decoration to apply over assigned `decoratedItem`. */
@property (assign) GBDecorationType decorationType;

/** The `GBParagraphItem` we're decorating. */
@property (retain) GBParagraphItem *decoratedItem;

@end
