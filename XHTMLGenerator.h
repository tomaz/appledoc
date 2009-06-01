//
//  XHTMLGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "GeneratorBase.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines a concrete @c GeneratorBase that generates XHTML output.
*/
@interface XHTMLGenerator : GeneratorBase

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Member helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the given member title.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberTitleToData:(NSMutableData*) data
						fromNode:(NSXMLElement*) node;

/** Appends the given member overview description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberOverviewToData:(NSMutableData*) data
						   fromNode:(NSXMLElement*) node;

/** Appends the given member prototype description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberPrototypeToData:(NSMutableData*) data
							fromNode:(NSXMLElement*) node;

/** Appends the given member section type description.￼

The type should be one of the following:
- @c kTKMemberSectionParameters: The array of all parameters will be returned.
- @c kTKMemberSectionExceptions: The array of all exceptions will be returned.
 
@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@param type The member section type.
@param title The desired section title.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberSectionToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node
							  type:(int) type
							 title:(NSString*) title;

/** Appends the given member return description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberReturnToData:(NSMutableData*) data
						 fromNode:(NSXMLElement*) node;

/** Appends the given member discussion description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberDiscussionToData:(NSMutableData*) data
							 fromNode:(NSXMLElement*) node;

/** Appends the given member warning description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberWarningToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node;

/** Appends the given member bug description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberBugToData:(NSMutableData*) data
					  fromNode:(NSXMLElement*) node;

/** Appends the given member see also section description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberSeeAlsoToData:(NSMutableData*) data
						  fromNode:(NSXMLElement*) node;

/** Appends the given member declaration file description.￼

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The member node to get information from.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
*/
- (void) appendMemberFileToData:(NSMutableData*) data
					   fromNode:(NSXMLElement*) node;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Description helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the brief description to the given data.￼

First the brief description is retreived from the given node, then the data from the 
retreived nodes is converted to a proper XHTML format and is then appended to the end 
of the given data.

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The description node which brief subcsection to append.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see appendDetailedDescriptionToData:fromNode:
*/
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromNode:(NSXMLElement*) node;

/** Appends the detailed description to the given data.￼

First the detailed description is retreived from the given node, then the data from the 
retreived nodes is converted to a proper XHTML format and is then appended to the end 
of the given data.

@param data ￼￼￼￼￼￼The data to append to.
@param node ￼￼￼￼￼￼The description node which detailed subcsection to append.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see appendBriefDescriptionToData:fromNode:
*/
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromNode:(NSXMLElement*) node;

/** Converts the description XML from the given node to proper XHTML format and appends
it to the given data.￼

This method will take care of converting the XML nodes to proper XHTML tags, including
computer code, paragraphs, links etc.
 
@param data The data to append to.
@param node ￼￼￼￼￼￼The description subnode which data to convert.
@exception ￼￼￼￼￼NSException Thrown if convertion fails.
*/
- (void) appendDescriptionToData:(NSMutableData*) data 
						fromNode:(NSXMLElement*) node;

@end
