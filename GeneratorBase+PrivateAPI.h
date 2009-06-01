//
//  GeneratorBase+PrivateAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneratorBase.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper methods private for the @c GeneratorBase and it's subclasses.
*/
@interface GeneratorBase (PrivateAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Section parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the section name from the given section node.￼

@param node ￼￼￼￼￼￼The section node which name to return.
@return ￼￼￼￼Returns the section name or @c nil if not found.
*/
- (NSString*) extractSectionName:(NSXMLElement*) node;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Members parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the member type fromt he given node.￼

The result is one of the following:
- @c kTKMemberTypeClass: The member is a class method.
- @c kTKMemberTypeInstance: The member is an instance method.
- @c kTKMemberTypeProperty: The member is a property.

@param node ￼￼￼￼￼￼The member node which type to return.
@return ￼￼￼￼Returns the member kind.
*/
- (int) extractMemberType:(NSXMLElement*) node;

/** Extracts the member name from the given member node.￼

@param node ￼￼￼￼￼￼The member node which name to return.
@return ￼￼￼￼Returns the member name or @c nil if not found.
*/
- (NSString*) extractMemberName:(NSXMLElement*) node;

/** Extracts the member selector name from the given member node.￼

@param node ￼￼￼￼￼￼The member node which selector name to return.
@return ￼￼￼￼Returns the member selector name or @c nil if not found.
*/
- (NSString*) extractMemberSelector:(NSXMLElement*) node;

/** Extracts the member file name from the given member node.￼

@param node ￼￼￼￼￼￼The member node which file name to return.
@return ￼￼￼￼Returns the member file name or @c nil if not found.
*/
- (NSString*) extractMemberFile:(NSXMLElement*) node;

/** Extracts the member prototype node from the given member node.￼

The returned node can be used by @c extractPrototypeSubnodesFromNode:() to get 
individual components. Then use @c extractPrototypeSubnodeTypeFromItem:() and
@c extractPrototypeSubnodeValueFromItem:() to get data for the individual components.
 
@param node ￼￼￼￼￼￼The member node which prototype node to return.
@return ￼￼￼￼Returns the member prototype node or @c nil if not found.
*/
- (NSXMLElement*) extractMemberPrototypeNode:(NSXMLElement*) node;

/** Extracts the member description node from the given member node.

The returned node can be used by @c extractBriefDescriptionFromNode:(),
@c extractBriefSubnodesFromNode:() and @c extractDetailSubnodesFromNode:() to get
individual description components.

@param node ￼￼￼￼￼￼The member node which description node to return.
@return ￼￼￼￼Returns the member description node or @c nil if not found.
*/
- (NSXMLElement*) extractMemberDescriptionNode:(NSXMLElement*) node;

/** Extracts the member section nodes from the given mem￼ber node.
 
The type can be one of the following:
- @c kTKMemberSectionParameters: The array of all parameters will be returned.
- @c kTKMemberSectionExceptions: The array of all exceptions will be returned.
 
Since all sections have the same layout, all section helpers can be used. The section
helpers are:
- @c extractMemberSectionSubnodes:()
- @c extractMemberSectionItemType:()
- @c extractMemberSectionItemValue:()

@param node ￼￼￼￼￼￼The member node which parameters to return.
@param type The type of section to return.
@return ￼￼￼￼Returns the array of @c NSXMLElement representing the member's parameters or
	@c nil if not found.
@warning Passing a @c type value other than one of the described here-in, may result in
	unpredictable behavior.
*/
- (NSArray*) extractMemberSectionNodes:(NSXMLElement*) node 
								  type:(int) type;

/** Extracts the member return node contents fromthe given member node.￼

The returned value contains the same layout as any other brief or detailed description
node, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subnode is contained as
the child node.

@param node ￼￼￼￼￼￼The member node which return description to get.
@return ￼￼￼￼Returns the return node of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
*/
- (NSXMLElement*) extractMemberReturnNode:(NSXMLElement*) node;

/** Extracts the member warning node contents fromthe given member node.￼

The returned value contains the same layout as any other brief or detailed description
node, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subnode is contained as
the child node.

@param node ￼￼￼￼￼￼The member node which warning description to get.
@return ￼￼￼￼Returns the warning node of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
*/
- (NSXMLElement*) extractMemberWarningNode:(NSXMLElement*) node;

/** Extracts the member bug node contents from the given member node.￼

The returned value contains the same layout as any other brief or detailed description
node, so it can be treated in the same way, including all formatting and other specifics
such as links generation. In most cases, at last one paragraph subnode is contained as
the child node.

@param node ￼￼￼￼￼￼The member node which bug description to get.
@return ￼￼￼￼Returns the bug node of the given member or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
*/
- (NSXMLElement*) extractMemberBugNode:(NSXMLElement*) node;

/** Extracts the member see also subnodes from the given member node.￼

The returned array contains all see also items. Each item returned in the resulting
array contains the same layout as any other brief or detailed description node, so it
can be treated in the same way, including all formatting and other specifics such as
links generation.

@param node ￼￼￼￼￼￼The member node which see also list to get.
@return ￼￼￼￼Returns the array of @c NSXMLElement nodes representing individual see also items
	or @c nil if not found.
@exception ￼￼￼￼￼NSException Thrown if extraction fails.
*/
- (NSArray*) extractMemberSeeAlsoItems:(NSXMLElement*) node;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Member section parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the prototype subnodes from the given prototype node.￼
 
@param node ￼￼￼￼￼￼The prototype node which subnodes to return.
@return ￼￼￼￼Returns the array pf prototype contents or @c nil if no parameter node is found.
*/
- (NSArray*) extractMemberSectionSubnodes:(NSXMLElement*) node;

/** Extracts the given prototype item type.￼

This can be used over the items of the array returned from
@c extractPrototypeSubnodesFromNode:(). Possible return values are:
- @c kTKPrototypeValue: The item represents a value.
- @c kTKPrototypeParameter: The item represents a parameter name.

To get the actual value, use @c extractPrototypeSubnodeValueFromItem:() passing the 
result of this method as the @c type parameter.

@param item ￼￼￼￼￼￼The prototype item to check.
@return ￼￼￼￼Returns the type of the given item.
*/
- (int) extractMemberSectionItemType:(id) item;

/** Extracts the given prototype component value from the given prototype item.￼

This can be used over the items of the array returned from
@c extractPrototypeSubnodesFromNode:().
 
@param item ￼￼￼￼￼￼The prototype item to check.
@return ￼￼￼￼Returns the string value representation of the given prototype item.
*/
- (NSString*) extractMemberSectionItemValue:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parameters parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the parameter name from the given parameter node.￼

@param node ￼￼￼￼￼￼The parameter node which name to return.
@return ￼￼￼￼Returns the parameter name or @c nil if not found.
*/
- (NSString*) extractParameterName:(NSXMLElement*) node;

/** Extracts the parameter description node from the given parameter node.

The returned node can be used by @c extractBriefDescriptionFromNode:(),
@c extractBriefSubnodesFromNode:() and @c extractDetailSubnodesFromNode:() to get
individual description components.

@param node ￼￼￼￼￼￼The parameter node which description node to return.
@return ￼￼￼￼Returns the parameter description node or @c nil if not found.
*/
- (NSXMLElement*) extractParameterDescriptionNode:(NSXMLElement*) node;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Descriptions parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the brief description from the given description node.￼

This will return only the first paragraph text from the given node if it exists.

@param node ￼￼￼￼￼￼The description node which brief description to return.
@return ￼￼￼￼Returns the first brief description paragraph text or @c nil if not found.
*/
- (NSString*) extractBriefDescriptionFromNode:(NSXMLElement*) node;

/** Extracts the brief description subnodes from the given description node.￼
 
Note that this method assumes there can only be one brief subnode for each description.

@param node ￼￼￼￼￼￼The description node which brief description subset to return.
@return ￼￼￼￼Returns the brief node contents or @c nil if brief is empty.
*/
- (NSArray*) extractBriefSubnodesFromNode:(NSXMLElement*) node;

/** Extracts the detailed description subnodes from the given description node.￼
 
Note that this method assumes there can only be one detailed subnode for each description.

@param node ￼￼￼￼￼￼The description node which detailed description subset to return.
@return ￼￼￼￼Returns the detailed node contents or @c nil if details are empty.
*/
- (NSArray*) extractDetailSubnodesFromNode:(NSXMLElement*) node;

/** Determines if at least one of the given brief or detailed subnodes is used or not.￼

@param nodes ￼￼￼￼￼￼The array returned from description parsing methods.
@return ￼￼￼￼Returns @c YES if at least one subnode contains some text.
*/
- (BOOL) isDescriptionUsed:(NSArray*) nodes;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Miscellaneous parsing helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the given subnode from the given node.￼

Note that this method always returns the first subnode if more than one exists.

@param node ￼￼￼￼￼￼The node to extract from.
@param name The name of the subnode to extract.
@return ￼￼￼￼Returns the given subnode or @c nil if doesn't exist.
*/
- (NSXMLElement*) extractSubnodeFromNode:(NSXMLElement*) node
								withName:(NSString*) name;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper generation methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the given string to the end of the given data, followed by a new line.￼

@param string ￼￼￼￼￼￼The string to append before the new line.
@param data ￼￼￼￼￼￼The data to append to.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendLine:(NSString*) string toData:(NSMutableData*) data;

/** Appends the given string to the end of the given data.￼

@param string ￼￼￼￼￼￼The string to append.
@param data ￼￼￼￼￼￼The data to append to.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendString:(NSString*) string toData:(NSMutableData*) data;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns current output title. */
@property(readonly) NSString* title;

/** Returns current object name. */
@property(readonly) NSString* objectName;

/** Returns current object kind. */
@property(readonly) NSString* objectKind;

/** Returns the names of the class, the current object belongs to.
 
At the moment this is only applicable for categories. */
@property(readonly) NSString* objectClass;

/** Returns current object cleaned XML document. */
@property(readonly) NSXMLDocument* objectMarkup;

/** Returns current object relative directory within the generated output.

This is only the directory and nothing else, in contrary to @c objectRelativePath()
which also returns the file name. */
@property(readonly) NSString* objectRelativeDir;

/** Returns current object relative path within the generated output.
 
This returns the directory and the object name without the extension (the extension should
be specified by each concrete @c GeneratorBase class). See also @c objectRelativeDir(). */
@property(readonly) NSString* objectRelativePath;

@end
