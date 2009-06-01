//
//  GeneratorBase+ObjectParsingAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneratorBase.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper methods private for the @c GeneratorBase and it's subclasses that
help parsing object related documentation.
*/
@interface GeneratorBase (ObjectParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object info items parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the object info item reference value for the given item.￼

@param item ￼￼￼￼￼￼The item which reference to te return.
@return ￼￼￼￼Returns the item reference or @c nil if not found.
@see extractObjectInfoItemValue:
*/
- (NSString*) extractObjectInfoItemRef:(id) item;

/** Extracts the object info item value for the given item.￼

@param item ￼￼￼￼￼￼The item which value to te return.
@return ￼￼￼￼Returns the item value or @c nil if not found.
@see extractObjectInfoItemRef:
*/
- (NSString*) extractObjectInfoItemValue:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object tasks parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the task name from the given task item.￼

@param item ￼￼￼￼￼￼The task item which name to return.
@return ￼￼￼￼Returns the section name or @c nil if not found.
*/
- (NSString*) extractObjectTaskName:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object members parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the member type fromt he given item.￼

The result is one of the following:
- @c kTKMemberTypeClass: The member is a class method.
- @c kTKMemberTypeInstance: The member is an instance method.
- @c kTKMemberTypeProperty: The member is a property.

@param item ￼￼￼￼￼￼The member item which type to return.
@return ￼￼￼￼Returns the member kind.
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (int) extractObjectMemberType:(id) item;

/** Extracts the member name from the given member item.￼

@param item ￼￼￼￼￼￼The member item which name to return.
@return ￼￼￼￼Returns the member name or @c nil if not found.
@see extractObjectMemberType:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (NSString*) extractObjectMemberName:(id) item;

/** Extracts the member selector name from the given member item.￼

@param item ￼￼￼￼￼￼The member item which selector name to return.
@return ￼￼￼￼Returns the member selector name or @c nil if not found.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (NSString*) extractObjectMemberSelector:(id) item;

/** Extracts the member file name from the given member item.￼

@param item ￼￼￼￼￼￼The member item which file name to return.
@return ￼￼￼￼Returns the member file name or @c nil if not found.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (NSString*) extractObjectMemberFile:(id) item;

/** Extracts the member prototype item from the given member item.￼

The returned item can be used by @c extractPrototypeSubitemsFromItem:() to get 
individual components. Then use @c extractPrototypeSubnodeTypeFromItem:() and
@c extractPrototypeSubnodeValueFromItem:() to get data for the individual components.
 
@param item ￼￼￼￼￼￼The member item which prototype item to return.
@return ￼￼￼￼Returns the member prototype item or @c nil if not found.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
 
@see extractObjectMemberPrototypeSubitems:
@see extractObjectMemberPrototypeItemType:
@see extractObjectMemberPrototypeItemValue:
*/
- (id) extractObjectMemberPrototypeItem:(id) item;

/** Extracts the member description item from the given member item.

The returned item can be used by @c extractBriefDescriptionFromItem:(),
@c extractBriefParagraphsFromItem:() and @c extractDetailParagraphsFromItem:() to get
individual description components.

@param item ￼￼￼￼￼￼The member item which description item to return.
@return ￼￼￼￼Returns the member description item or @c nil if not found.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (id) extractObjectMemberDescriptionItem:(id) item;

/** Extracts the member section items from the given mem￼ber item.
 
The type can be one of the following:
- @c kTKMemberSectionParameters: The array of all parameters will be returned.
- @c kTKMemberSectionExceptions: The array of all exceptions will be returned.
 
Since all sections have the same layout, all section helpers can be used. The section
helpers are:
- @c extractObjectMemberPrototypeSubitems:()
- @c extractObjectMemberPrototypeItemType:()
- @c extractObjectMemberPrototypeItemValue:()

@param item ￼￼￼￼￼￼The member item which parameters to return.
@param type The type of section to return.
@return ￼￼￼￼Returns the array of items representing the member's parameters or @c nil if not found.
@warning Passing a @c type value other than one of the described here-in, may result in
	unpredictable behavior.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (NSArray*) extractObjectMemberSectionItems:(id) item 
										type:(int) type;

/** Extracts the member return item contents fromthe given member item.￼

The returned value contains the same layout as any other brief or detailed description
item, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subitem is contained as
the child item.

@param item ￼￼￼￼￼￼The member item which return description to get.
@return ￼￼￼￼Returns the return item of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (id) extractObjectMemberReturnItem:(id) item;

/** Extracts the member warning item contents fromthe given member item.￼

The returned value contains the same layout as any other brief or detailed description
item, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subitem is contained as
the child item.

@param item ￼￼￼￼￼￼The member item which warning description to get.
@return ￼￼￼￼Returns the warning item of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberBugItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (id) extractObjectMemberWarningItem:(id) item;

/** Extracts the member bug item contents from the given member item.￼

The returned value contains the same layout as any other brief or detailed description
item, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subitem is contained as
the child item.

@param item ￼￼￼￼￼￼The member item which bug description to get.
@return ￼￼￼￼Returns the bug item of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberSeeAlsoItems:
*/
- (id) extractObjectMemberBugItem:(id) item;

/** Extracts the member see also subitems from the given member item.￼

The returned array contains all see also items. Each item returned in the resulting
array contains the same layout as any other brief or detailed description item, so it
can be treated in the same way, including all formatting and other specifics such as
links generation.

@param item ￼￼￼￼￼￼The member item which see also list to get.
@return ￼￼￼￼Returns the array of items representing individual see also items or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
@see extractObjectMemberType:
@see extractObjectMemberName:
@see extractObjectMemberSelector:
@see extractObjectMemberFile:
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberDescriptionItem:
@see extractObjectMemberSectionItems:type:
@see extractObjectMemberReturnItem:
@see extractObjectMemberWarningItem:
@see extractObjectMemberBugItem:
*/
- (NSArray*) extractObjectMemberSeeAlsoItems:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object member prototype parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the member prototype subitems from the given member item.￼
 
@param item ￼￼￼￼￼￼The member prototype item which subitems to return.
@return ￼￼￼￼Returns the array of prototype contents or @c nil if no content is found.
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberPrototypeItemType:
@see extractObjectMemberPrototypeItemValue:
*/
- (NSArray*) extractObjectMemberPrototypeSubitems:(id) item;

/** Extracts the given member prototype item type.￼

This can be used over the items of the array returned from
@c extractObjectMemberPrototypeSubitems:(). Possible return values are:
- @c kTKPrototypeValue: The item represents a value.
- @c kTKPrototypeParameter: The item represents a parameter name.

To get the actual value, use @c extractPrototypeSubnodeValueFromItem:() passing the 
result of this method as the @c type parameter.

@param item ￼￼￼￼￼￼The prototype item to check.
@return ￼￼￼￼Returns the type of the given item.
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberPrototypeSubitems:
@see extractObjectMemberPrototypeItemValue:
*/
- (int) extractObjectMemberPrototypeItemType:(id) item;

/** Extracts the given prototype component value from the given prototype item.￼

This can be used over the items of the array returned from
@c extractPrototypeSubitemsFromItem:().
 
@param item ￼￼￼￼￼￼The prototype item to check.
@return ￼￼￼￼Returns the string value representation of the given prototype item.
@see extractObjectMemberPrototypeItem:
@see extractObjectMemberPrototypeSubitems:
@see extractObjectMemberPrototypeItemType:
*/
- (NSString*) extractObjectMemberPrototypeItemValue:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parameters parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the parameter name from the given parameter item.￼

@param item ￼￼￼￼￼￼The parameter item which name to return.
@return ￼￼￼￼Returns the parameter name or @c nil if not found.
*/
- (NSString*) extractObjectParameterName:(id) item;

/** Extracts the parameter description item from the given parameter item.

The returned item can be used by @c extractBriefDescriptionFromItem:(),
@c extractBriefParagraphsFromItem:() and @c extractDetailParagraphsFromItem:() to get
individual description components.

@param item ￼￼￼￼￼￼The parameter item which description item to return.
@return ￼￼￼￼Returns the parameter description item or @c nil if not found.
*/
- (id) extractObjectParameterDescriptionNode:(id) item;

@end
