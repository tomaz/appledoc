//
//  DocSetOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "OutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines a concrete @c OutputGenerator which generates documentation set.

The generator depends on @c XMLOutputGenerator and @c XHTMLOutputGenerator output. It 
generates the documentation set source plist, index and nodes XML source files, invokes
indexing through the @c docsetutils command line utility and installs the documentation
set to the Xcode documentation window.
 
Since the @c DocSetOutputGenerator doesn't generate the actual content files itself, it
must be given the locations, names and extensions of the source files. This should be
set through the @c documentationFilesInfoProvider() property before generation starts. If the
clients forget to set this property, generation will fail immediately.
*/
@interface DocSetOutputGenerator : OutputGenerator
{
	id<OutputInfoProvider> documentationFilesInfoProvider;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Documentation set handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates the DocSet source plist file.

This file is used when creating the documentation set. The file is only created if it
doesn't exist yet. If it exists, this method will exit without doing anything. This
allows the user to change the data in the file as he see fit after it was created.

This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.
 
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

This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.

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

This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.

@exception NSException Thrown if creation fails.
@see createDocSetSourcePlistFile
@see createDocSetNodesFile
@see createDocSetBundle
*/
- (void) createDocSetTokesFile;

/** Creates DocSet bundle.

This message should be sent after all source files required for documentation set creation
have been created. It will copy all html files found at path returned from
@c documentationFilesInfoProvider to the documentation set output directory and will 
invoke the indexing of the files with the help of nodes and tokes files.
 
This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.

@exception NSException Thrown if creation fails.
@see createDocSetSourcePlistFile
@see createDocSetNodesFile
@see createDocSetTokesFile
@see addDocSetNodeToElement:fromHierarchyData:
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

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Sets or returns the @c OutputInfoProvider conformer that provides information about
documentation files which should be included in the documentation set.￼￼

This value is used to determine the path to the documentation HTML files so that they
can be copied to the documentation set.

@warning Clients need to set this before starting output generation. If they fail to
	provide a valid object, generation immediately fails with an exception.
*/
@property(retain) id<OutputInfoProvider> documentationFilesInfoProvider;

/** Returns the temporary documentation set contents path.￼

@see outputResourcesPath
@see outputDocumentsPath
*/
@property(readonly) NSString* outputContentsPath;

/** Returns the temporary documentation set resources path.￼

@see outputContentsPath
@see outputDocumentsPath
*/
@property(readonly) NSString* outputResourcesPath;

/** Returns the temporary documentation set documents path.￼

@see outputContentsPath
@see outputResourcesPath
*/
@property(readonly) NSString* outputDocumentsPath;

@end
