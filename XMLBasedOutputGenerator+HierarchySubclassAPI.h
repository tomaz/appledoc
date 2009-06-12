//
//  XMLBasedOutputGenerator+HierarchySubclassAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLBasedOutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper virtual methods for the @c XMLBasedOutputGenerator subclasses that help
hierarchy output generation.
*/
@interface XMLBasedOutputGenerator (HierarchySubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass hierarchy file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any header text before the actual generation starts.

The message is sent from the @c XMLBasedOutputGenerator::outputDataForHierarchy() as the first message. 
It gives subclasses a chance to append data to the output before the actual output generation 
starts. After this message is sent, the rest of the messages are followed and as the last one,
@c appendHierarchyFooterToData:() is sent.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see XMLBasedOutputGenerator::outputDataForHierarchy
@see appendHierarchyFooterToData:
*/
- (void) appendHierarchyHeaderToData:(NSMutableData*) data;

/** Appends any footer text after output generation ends.

The message is sent from the @c XMLBasedOutputGenerator::outputDataForHierarchy() as the last message. It 
gives subclasses a chance to append data to the output after the rest of the output is 
generated. This is ussually the place to "close" open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see XMLBasedOutputGenerator::outputDataForHierarchy
@see appendHierarchyHeaderToData:
*/
- (void) appendHierarchyFooterToData:(NSMutableData*) data;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass hierarchy group handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any hierarchy group header text before the actual group items generation starts.

The message is sent from the @c XMLBasedOutputGenerator::outputDataForHierarchy() just before hierarchy 
group items are generated. It gives subclasses a chance to append data to the output before 
the generation for group items starts. After this message is sent, at least one 
@c appendHierarchyGroupItemToData:fromItem:index:() message is sent and then 
@c appendHierarchyGroupFooterToData:() is sent at the end.
 
@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see XMLBasedOutputGenerator::outputDataForHierarchy
@see appendHierarchyGroupItemToData:fromItem:index:
@see appendHierarchyGroupFooterToData:
*/
- (void) appendHierarchyGroupHeaderToData:(NSMutableData*) data;

/** Appends any hierarchy group footer text after the group items generation ends.

The message is sent from the @c XMLBasedOutputGenerator::outputDataForHierarchy() as the last group 
generation message. It gives subclasses a chance to append data to the output after the 
generation for hierarchy group ends. This is ussually the place to "close" open tags or 
similar.
 
Note that this message is sent after all children of all the group items are processed
so that the subclass can safely assume the whole group is processed well.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see XMLBasedOutputGenerator::outputDataForHierarchy
@see appendHierarchyGroupHeaderToData:
@see appendHierarchyGroupItemToData:fromItem:index:
*/
- (void) appendHierarchyGroupFooterToData:(NSMutableData*) data;

/** Appends the given hierarchy group item data.

This message is sent from @c XMLBasedOutputGenerator::outputDataForHierarchy() for each group member. 
The subclass should append the data for the given item. The subclass can get more 
information about the member by using the hierarchy member data methods from the 
@c XMLBasedOutputGenerator(HierarchyParsingAPI) category.
 
@param data The data to append to. This is guaranteed to be non @c null.
@param item The data item describing the given member.
@param index Zero based index of the member within the group.
@exception NSException Thrown if appending fails.
@see XMLBasedOutputGenerator::outputDataForHierarchy
@see appendHierarchyGroupHeaderToData:
@see appendHierarchyGroupFooterToData:
@see generateHierarchyGroupChildrenToData:forItem:
*/
- (void) appendHierarchyGroupItemToData:(NSMutableData*) data
							   fromItem:(id) item
								  index:(int) index;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Hierarchy children parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates￼ the given hierarchy item's children documentation .

This should be sent by the subclass from it's ￼@c appendHierarchyGroupItemToData:fromItem:index:()
override at the point where all children should be processed. It will check if any
children are defined for the given item and will in turn send the subclass all hierarchy
group appending methods: @c appendHierarchyGroupHeaderToData:(), 
@c appendHierarchyGroupItemToData:fromItem:index:() and
@c appendHierarchyGroupFooterToData:() for all children, including their children
and so on recursively until no more children are found.

@param data The @c NSMutableData to append to.
@param item The item for which to generate children output.
@exception NSException Thrown if generation fails.
*/
- (void) generateHierarchyGroupChildrenToData:(NSMutableData*) data
									  forItem:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns current hierarchy output title. */
@property(readonly) NSString* hierarchyTitle;

/** Returns current hierarchy cleaned XML document. */
@property(readonly) NSXMLDocument* hierarchyMarkup;

@end
