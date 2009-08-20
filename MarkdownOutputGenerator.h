//
//  MarkdownOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "XMLBasedOutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines a concrete @c XMLBasedOutputGenerator that generates Markdown output.
 
Basically this produces text files which are fairly readable for humans and can be
converted to simple HTML as a bonus (although @c XHTMLOutputGenerator is probably a
better HTML output generator solution if HTML is the desired output). See 
http://daringfireball.net/projects/markdown for details on Markdown syntax.
*/
@interface MarkdownOutputGenerator : XMLBasedOutputGenerator
{
	NSMutableDictionary* linkReferences;
	NSString* descriptionBlockPrefix;
	NSString* descriptionBlockSuffix;
	NSString* descriptionBlockLinePrefix;
	BOOL descriptionBlockPrefixFirstLine;
	BOOL descriptionDelimitSingleParameters;
	BOOL descriptionDelimitLastParameter;
	BOOL descriptionMarkEmphasis;
	int descriptionBlockLineCount;
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
retreived nodes is converted to a proper Markdown format and is then appended to the end 
of the given data.
 
Note that the generated output is affected by object's description variables and flags.
@c resetDescriptionVarsToDefaults() can be used to reset these to defaults. See
See @c resetDescriptionVarsToDefaults for the list of the variables and their meanings.

@param data The data to append to.
@param item The description item which brief subcsection to append.
@exception NSException Thrown if appending fails.
@see appendDetailedDescriptionToData:fromItem:
@see appendDescriptionToData:fromDescriptionItems:
@see resetDescriptionVarsToDefaults
*/
- (void) appendBriefDescriptionToData:(NSMutableData*) data 
							 fromItem:(id) item;

/** Appends the detailed description to the given data.

First the detailed description is retreived from the given node, then the data from the 
retreived nodes is converted to a proper Markdown format and is then appended to the end 
of the given data.
 
Note that the generated output is affected by object's description variables and flags.
@c resetDescriptionVarsToDefaults() can be used to reset these to defaults. See
See @c resetDescriptionVarsToDefaults for the list of the variables and their meanings.

@param data The data to append to.
@param item The description item which detailed subcsection to append.
@exception NSException Thrown if appending fails.
@see appendBriefDescriptionToData:fromItem:
@see appendDescriptionToData:fromDescriptionItems:
@see resetDescriptionVarsToDefaults
*/
- (void) appendDetailedDescriptionToData:(NSMutableData*) data 
								fromItem:(id) item;

/** Converts the description data from the given paragraph to proper Markdown format and 
appends it to the given data.

Note that the generated output is affected by object's description variables and flags.
@c resetDescriptionVarsToDefaults() can be used to reset these to defaults. See
See @c resetDescriptionVarsToDefaults for the list of the variables and their meanings.

@param data The data to append to.
@param items The array of description items which data to convert. If @c nil nothing happens.
@exception NSException Thrown if convertion fails.
@see appendBriefDescriptionToData:fromItem:
@see appendDetailedDescriptionToData:fromItem:
@see appendParagraphToData:fromString:
@see resetDescriptionVarsToDefaults
*/
- (void) appendDescriptionToData:(NSMutableData*) data 
			fromDescriptionItems:(NSArray*) items;

/** Appends the given string containing a paragraph text to the￼ given data.

This method cleans the output and takes care of formatting the text to fit to the desired 
line width￼. It is sent automatically from @c appendDescriptionToData:fromDescriptionItems:()
and is not meant to be used otherwise.
 
Note that this only appends the given paragraph text, it doesn't delimit the paragraph
with an empty line and doesn't end the paragraph with a new line either.

@param data The data to append to.
@param string The paragraph text.
@param prefix The prefix to append before each line.
@param wrap If @c YES, paragraph text should be wrapped according to wrapping options,
	otherwise not.
@exception NSException Thrown if appending fails.
@see appendDescriptionToData:fromDescriptionItems:
*/
- (void) appendParagraphToData:(NSMutableData*) data
					fromString:(NSString*) string
					linePrefix:(NSString*) prefix
						  wrap:(BOOL) wrap;

/** Resets all description variables to default values.￼
 
The description variables and their default values are:
- @c descriptionDelimitSingleParameters: A boolean value indicating whether single
	parameters should be delimited by a new line or not. If @c YES, all parameters are
	delimited, if @c NO, parameters are delimited by a new line only if two or more are
	detected. Defaults to @c YES.
- @c descriptionDelimitLastParameter: A boolean value indicating whether last parameter
	should be delimited by a new line or not. Note that if this is set to @c NO, the
	@c descriptionDelimitSingleParameters has no effect. Defaults to @c YES.
- @c descriptionMarkEmphasis: A boolean value indicating whether strong and emphasis
	markers should be used or not. Defaults to @c YES.

@see appendBriefDescriptionToData:fromItem:
@see appendDetailedDescriptionToData:fromItem:
@see appendDescriptionToData:fromDescriptionItems:
*/
- (void) resetDescriptionVarsToDefaults;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the header of the given level for the given string.￼

Depending of the settings, this creates properly formatted header for the given string.￼
Afterwards it automatically adds one empty line.

@param data The data to append to.
@param string The header string.
@param level The header level. Should be between @c 1 and @c 10.
@exception NSException Thrown if the given level is not within expected range or appending fails.
*/
- (void) appendHeaderToData:(NSMutableData*) data
				  forString:(NSString*) string
					  level:(int) level;

/** Appends the underline data for the given string.￼
 
This is mostly used for generating underlines for the titles.￼ Note that nothing will be
output if the given @c string or @c underline are @c nil or empty strings.

@param data The data to append to.
@param string The string which should be underlines.
@param underline The underline string. Should only contain 1 char!
@exception NSException Thrown if appending fails.
*/
- (void) appendUnderlineToData:(NSMutableData*) data
					 forString:(NSString*) string
					 underline:(NSString*) underline;

/** Appends link to the given data.￼

Depending on the style this either appends the link ID and the reference to the footnote
or the actual link.￼ If @c nil is passed for the reference, the method appends only the
given description. However @c description may not be @c nil in such case.

@param data The data to append to.
@param reference The link reference. May be @c nil to only use the description.
@param description The link description. May be @c nil to use the reference.
@exception NSException Thrown if the @c reference and the @c description are @c nil or 
	appending fails.
*/
- (void) appendLinkToData:(NSMutableData*) data
			fromReference:(NSString*) reference
		   andDescription:(NSString*) description;

/** Appends all link footnotes to the given data.￼

This message should be sent after handling the file is complete and all references
are in the temporary array.￼ This method will output the actual links as footnote
markdown style if necessary. If footnote links are disabled or there is no reference
for the current object, nothing happens.

@param data The data to append to.
@exception NSException Thrown if appending fails.
*/
- (void) appendLinkFootnotesToData:(NSMutableData*) data;

/** Formats a link from the given data.￼

Depending on the style this either formats the link as the reference to the footnote or
the actual link. If @c nil is passed for the reference, the method appends only the
given description. However @c description may not be @c nil in such case.￼
 
Note that if the given reference points to the object's member, the link is not generated.
Instead only the member name is emmited.
 
Note that in case footnote style is used, the receiver's footnote index is automatically 
incremented if necessary.

@param reference The link reference. May be @c nil to only use the description.
@param description The link description. May be @c nil to use the reference.
@return Returns the formatted link.
@exception NSException Thrown if the @c reference and the @c description are @c nil or 
	appending fails.
*/
- (NSString*) formatLinkFromReference:(NSString*) reference
					   andDescription:(NSString*) description;

@end
