//
//  GBParagraphItem.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Defines the base functionality for all paragraph items. */
@interface GBParagraphItem : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns new autoreleased instance. */
+ (id)paragraphItem;

///---------------------------------------------------------------------------------------
/// @name Values
///---------------------------------------------------------------------------------------

/** Item's string value.
 
 This is mainly used for debugging and unit tests.
 */
@property (copy) NSString *stringValue;

@end
