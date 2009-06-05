//
//  DoxygenConverter+DocSet.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoxygenConverter.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Implements documentation set related functionality for @c DoxygenConverter class.

This category creates the documentation set info plist and all required files required for
indexing the documentation set, it handles the indexing itself and prepares the
documentation set bundle as well as installs it to the @c Xcode documentation.
*/
@interface DoxygenConverter (DocSet)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Documentation set creation handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates the DocSet source plist file.

This file is used when creating the documentation set. The file is only created if it
doesn't exist yet. If it exists, this method will exit without doing anything. This
allows the user to change the data in the file as he see fit after it was created.

This message is automatically sent from @c DoxygenConverter::convert() in the proper order.
 
@exception NSException Thrown if creating the plist file fails.
@see createDocSetNodesFile
@see createDocSetTokesFile
@see createDocSetBundle
*/
- (void) createDocSetSourcePlistFile;

/** Creates DocSet Nodes.xml file.

The Nodes.xml file describes the structure of the documentation set and is used to
create a table of contents that users see in the Xcode documentation window. This file
is required when compiling the documentation set.

This message is automatically sent from @c DoxygenConverter::convert() in the proper order.

@exception NSException Thrown if creation fails.
@see createDocSetSourcePlistFile
@see createDocSetTokesFile
@see createDocSetBundle
@see addDocSetNodeToElement:fromHierarchyData:
*/
- (void) createDocSetNodesFile;

/** Creates DocSet Tokens.xml file.

The Tokens.xml file associate symbol names with locations in the documentation files.
This file is used for creating the symbol index for the documentation set.

This message is automatically sent from @c DoxygenConverter::convert() in the proper order.

@exception NSException Thrown if creation fails.
@see createDocSetSourcePlistFile
@see createDocSetNodesFile
@see createDocSetBundle
*/
- (void) createDocSetTokesFile;

/** Creates DocSet bundle.

This message should be sent after all source files required for documentation set creation
have been created. It will copy all html files created in @c createCleanOutputDocumentation()
to the DocSet output directory and will invoke the indexing of the files with the help of
nodes and tokes files.
 
This message is automatically sent from @c DoxygenConverter::convert() in the proper order.

@exception NSException Thrown if creation fails.
@see createDocSetSourcePlistFile
@see createDocSetNodesFile
@see createDocSetTokesFile
*/
- (void) createDocSetBundle;

/** Adds a new DocSet node as the child of the given parent element.￼

The given hierarchy data ￼contains the description of the node to add. The added node is
either of the type folder if it contains children or it is a leaf otherwise. The methods
will recursively add all subnodes as well.

@param parent The Nodes.xml element to which to add new node.
@param data The hierarchy object data that describes the node.
@exception NSException Thrown if adding fails.
@see createDocSetNodesFile
*/
- (void) addDocSetNodeToElement:(NSXMLElement*) parent
			  fromHierarchyData:(NSDictionary*) data;

@end
