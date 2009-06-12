//
//  XMLBasedOutputGenerator+IndexParsingAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLBasedOutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper methods private for the @c XMLBasedOutputGenerator and it's subclasses that
help parsing index related documentation.
*/
@interface XMLBasedOutputGenerator (IndexParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Index group items parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the index group item reference value for the given item.

@param item The item which reference to return.
@return Returns the item reference or @c nil if not found.
@see extractIndexGroupItemName:
*/
- (NSString*) extractIndexGroupItemRef:(id) item;

/** Extracts the index group item name for the given item.

@param item The item which value to return.
@return Returns the item value or @c nil if not found.
@see extractIndexGroupItemRef:
*/
- (NSString*) extractIndexGroupItemName:(id) item;

@end
