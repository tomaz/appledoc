//
//  OutputGenerator+HierarchyParsingAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper methods private for the @c OutputGenerator and it's subclasses that
help parsing hierarchy related documentation.
*/
@interface OutputGenerator (HierarchyParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Hierarchy group items parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the hierarchy group item reference value for the given item.

@param item The item which reference to return.
@return Returns the item reference or @c nil if not found.
@see extractHierarchyGroupItemName:
@see extractHierarchyGroupItemChildren:
*/
- (NSString*) extractHierarchyGroupItemRef:(id) item;

/** Extracts the hierarchy group item name for the given item.

@param item The item which value to return.
@return Returns the item value or @c nil if not found.
@see extractHierarchyGroupItemRef:
@see extractHierarchyGroupItemChildren:
*/
- (NSString*) extractHierarchyGroupItemName:(id) item;

/** Extracts the hierarchy group item children for the given item.￼￼

@param item The item which children to return.
@return Returns a @c NSArray containing all children of the item or @c nil if item is leaf.
@see extractHierarchyGroupItemRef:
@see extractHierarchyGroupItemName:
*/
- (NSArray*) extractHierarchyGroupItemChildren:(id) item;

@end
