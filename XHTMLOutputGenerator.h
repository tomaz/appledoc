//
//  XHTMLOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines a concrete @c XMLBasedOutputGenerator that generates XHTML output.
*/
@interface XHTMLOutputGenerator : XMLBasedOutputGenerator
{
	BOOL indexProtocolsGroupAppended;
	BOOL indexCategoriesGroupAppended;
	NSString* hierarchyGroupIndent;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Object member helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the given member title.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberTitleToData:(NSMutableData*) data
							  fromItem:(id) item;

/** Appends the given member overview description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberOverviewToData:(NSMutableData*) data
								 fromItem:(id) item;

/** Appends the given member prototype description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberPrototypeToData:(NSMutableData*) data
								  fromItem:(id) item;

/** Appends the given member section type description.

The type should be one of the following:
- @c kTKObjectMemberSectionParameters: The array of all parameters will be returned.
- @c kTKObjectMemberSectionExceptions: The array of all exceptions will be returned.
 
@param data The data to append to.
@param item The member item to get information from.
@param type The member section type.
@param title The desired section title.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberSectionToData:(NSMutableData*) data
								fromItem:(id) item
									type:(int) type
								   title:(NSString*) title;

/** Appends the given member return description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberReturnToData:(NSMutableData*) data
							   fromItem:(id) item;

/** Appends the given member discussion description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberDiscussionToData:(NSMutableData*) data
								   fromItem:(id) item;

/** Appends the given member warning description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberWarningToData:(NSMutableData*) data
								fromItem:(id) item;

/** Appends the given member bug description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberBugToData:(NSMutableData*) data
							fromItem:(id) item;

/** Appends the given member see also section description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberSeeAlsoToData:(NSMutableData*) data
								fromItem:(id) item;

/** Appends the given member declaration file description.

@param data The data to append to.
@param item The member item to get information from.
@exception NSException Thrown if appending fails.
*/
- (void) appendObjectMemberFileToData:(NSMutableData*) data
							 fromItem:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Description helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the brief description to the given data.

First the brief description is retreived from the given node, then the data from the 
retreived nodes is converted to a proper XHTML format and is then appended to the end 
of the given data.

@param data The data to append to.
@param item The description item which brief subcsection to append.
@exception NSException Thrown if appending fails.
@see appendDetailedDescriptionToData:fromItem:
@see appendDescriptionToData:fromDescription:
*/
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromItem:(id) item;

/** Appends the detailed description to the given data.

First the detailed description is retreived from the given node, then the data from the 
retreived nodes is converted to a proper XHTML format and is then appended to the end 
of the given data.

@param data The data to append to.
@param item The description item which detailed subcsection to append.
@exception NSException Thrown if appending fails.
@see appendBriefDescriptionToData:fromItem:
@see appendDescriptionToData:fromDescription:
*/
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromItem:(id) item;

/** Converts the description data from the given paragraph to proper XHTML format and 
appends it to the given data.

This method will take care of converting the source data to proper XHTML tags, including
computer code, paragraphs, links etc. Note that this is the only place where the original
data XML structure is exposed to the class.
 
@param data The data to append to.
@param item The description paragraph which data to convert. If @c nil nothing will happen.
@exception NSException Thrown if convertion fails.
@see appendBriefDescriptionToData:fromItem:
@see appendDetailedDescriptionToData:fromItem:
*/
- (void) appendDescriptionToData:(NSMutableData*) data 
				 fromDescription:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends HTML file header to the given data.

The senders should provide the desired title and path and name of the linked stylesheet
file.

@param data The data to append to.
@param title The title to use for the header.
@param stylesheet The path and name of the linked stylesheet file.
@exception NSException Thrown if appending fails.
@see appendFileFooterToData:withLastUpdated:andIndexLink:
*/
- (void) appendFileHeaderToData:(NSMutableData*) data
					  withTitle:(NSString*) title
				  andStylesheet:(NSString*) stylesheet;

/** Appends HTML file footer to the given data.

The senders can optionally include last update time and back to index link.

@param data The data to append to.
@param showLastUpdate If @c YES, last updated time should be inserted.
@param showBackToIndex If @c YES, the link back to index should be inserted.
@exception NSException Thrown if appending fails.
@see appendFileHeaderToData:withTitle:andStylesheet:
*/
- (void) appendFileFooterToData:(NSMutableData*) data
				withLastUpdated:(BOOL) showLastUpdate
				   andIndexLink:(BOOL) showBackToIndex;

@end
