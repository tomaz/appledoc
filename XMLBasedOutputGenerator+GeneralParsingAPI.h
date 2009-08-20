//
//  XMLBasedOutputGenerator+GeneralParsingAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLBasedOutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines general helper methods private for the @c XMLBasedOutputGenerator and it's 
subclasses.
*/
@interface XMLBasedOutputGenerator (GeneralParsingAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Descriptions parsing support
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the first brief description paragraph from the given description item.

This will return only the first paragraph value from the given item if it exists. It is
useful for generating short descriptions for example.

@param item The description item which brief description to return.
@return Returns the first brief description paragraph text or @c nil if not found.
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see isDescriptionUsed:
*/
- (NSString*) extractBriefDescriptionFromItem:(id) item;

/** Extracts the brief description paragraphs from the given description item.
 
Note that this method assumes there can only be one brief description per a description
item passed to the method. Subclasses can use @c extractParagraphText: to get the actual
text of individual paragraphs.

@param item The description item which brief description paragraphs to return.
@return Returns the brief item paragraphs or @c nil if brief is empty.
@see extractBriefDescriptionFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionsFromItem:
@see extractDescriptionType:
@see extractDescriptionReference:
@see extractDescriptionText:
@see isDescriptionUsed:
*/
- (NSArray*) extractBriefDescriptionsFromItem:(id) item;

/** Extracts the detailed description paragraphs from the given description item.
 
Note that this method assumes there can only be one detailed description per a description
item passed to the method. Subclasses can use @c extractParagraphText: to get the actual
text of individual paragraphs.

@param item The description item which detailed description paragraphs to return.
@return Returns the detailed node paragraphs or @c nil if details are empty.
@see extractBriefDescriptionFromItem:
@see extractBriefDescriptionsFromItem:
@see extractDescriptionsFromItem:
@see extractDescriptionType:
@see extractDescriptionReference:
@see extractDescriptionText:
@see isDescriptionUsed:
*/
- (NSArray*) extractDetailDescriptionsFromItem:(id) item;

/** Extracts the paragraphs from the given item.￼

This method can be used for any item which contains the list of paragraphs. Internally
it is also used to extract the paragraphs in the @c extractBriefDescriptionsFromItem:()
and @c extractDetailDescriptionsFromItem:().￼

@param item The item which paragraphs contents to extract.
@return Returns the array of paragraphs or @c nil if no paragraph is found.
@see extractBriefDescriptionFromItem:
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionType:
@see extractDescriptionReference:
@see extractDescriptionText:
@see isDescriptionUsed:
*/
- (NSArray*) extractDescriptionsFromItem:(id) item;

/** Extracts the type of the given description item.￼

This method can be used to get the information about the type of the given description 
item extracted through one of the following methods: @c extractBriefDescriptionsFromItem:(),
@c extractDetailDescriptionsFromItem:(), @c extractDescriptionsFromItem:().
 
Possible return values are:
- @c kTKDescriptionParagraphStart: The description represents a paragraph block start 
	which ends with an @c kTKDescriptionParagraphEnd. In between any number of the other 
	items type may be extracted.
- @c kTKDescriptionParagraphEnd: The description represents a paragraph end. Each 
	paragraph block opened with @c kTKDescriptionParagraphStart ends with this item.
- @c kTKDescriptionCodeStart: The description represents a code block start 
	which ends with an @c kTKDescriptionCodeEnd. In between any number of the other 
	items type may be extracted.
- @c kTKDescriptionCodeEnd: The description represents a code end. Each code block opened 
	with @c kTKDescriptionCodeStart ends with this item.
- @c kTKDescriptionListStart: The description represents a list block start which ends 
	with an @c kTKDescriptionCodeEnd. In between any number of list item blocks may be
	reported.
- @c kTKDescriptionListEnd: The description represents a list end. Each list block opened 
	with @c kTKDescriptionListStart ends with this item.
- @c kTKDescriptionListItemStart: The description represents a list item block start 
	which ends with an @c kTKDescriptionListItemEnd. In between any number of the other 
	items type may be extracted.
- @c kTKDescriptionListItemEnd: The description represents a list item end. Each list item
	block opened with @c kTKDescriptionListItemStart ends with this item.
- @c kTKDescriptionStrongStart: The description represents a strong type block start which 
	ends with an @c kTKDescriptionStrongEnd. In between any number of the other items type 
	may be extracted.
- @c kTKDescriptionStrongEnd: The description represents a strong tyoe item end. Each 
	strong type block opened with @c kTKDescriptionStrongStart ends with this item.
- @c kTKDescriptionEmphasisStart: The description represents an emphasis type block start 
	which ends with an @c kTKDescriptionEmphasisEnd. In between any number of the other 
	items type may be extracted.
- @c kTKDescriptionEmphasisEnd: The description represents an emphasis type block end. Each 
	emphasis type block opened with @c kTKDescriptionEmphasisStart ends with this item.
- @c kTKDescriptionExampleStart The description represents an example block start which 
	ends with an @c kTKDescriptionExampleEnd. In between any number of other items may
	be reported (although example blocks ussually only contain @c kTKDescriptionText
	sub items).
- @c kTKDescriptionExampleEnd: The description represents an example block end. Each 
	example block opened with @c kTKDescriptionExampleStart ends with this item.
- @c kTKDescriptionReferenceStart: The description represents a reference block start 
	which ends with an @c kTKDescriptionReferenceEnd. The opening description should
	be querried for the actual link with @c extractDescriptionReference:(). The
	description name will be reported immediately after opening item with the
	@c kTKDescriptionText item, followed by the @c kTKDescriptionReferenceEnd.
- @c kTKDescriptionReferenceEnd: The description represents a reference item end. Each 
	reference block opened with @c kTKDescriptionReferenceStart ends with this item.
- @c kTKDescriptionText: The description represents a normal text. @c extractDescriptionText:() 
	message may be sent to get the text value.
 
@param item The item which type to return.
@return Returns the type of the given item.
@exception Thrown if the given item is not recognised.
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionsFromItem:
@see extractDescriptionReference:
@see extractDescriptionText:
*/
- (int) extractDescriptionType:(id) item;

/** Extracts the description reference from the ￼given description item.

This method can be used to get the information about the reference link from description 
item extracted through one of the following methods: @c extractBriefDescriptionsFromItem:(),
@c extractDetailDescriptionsFromItem:(), @c extractDescriptionsFromItem:().

@param description The @c kTKDescriptionReferenceStart description item to extract from.
@return Returns the reference value of the given item.
@warning @b Important: This only returns valid values for description types of 
	@c kTKDescriptionReferenceStart. It returns @c nil for all other description types.
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionsFromItem:
@see extractDescriptionType:
@see extractDescriptionText:
*/
- (NSString*) extractDescriptionReference:(id) description;

/** Extracts the description text from the ￼given description item.

This method can be used to get the information about the actual text from description 
item extracted through one of the following methods: @c extractBriefDescriptionsFromItem:(),
@c extractDetailDescriptionsFromItem:(), @c extractDescriptionsFromItem:().

@param item The @c kTKDescriptionText description item to extract from.
@return Returns the text value of the given item.
@warning @b Important: This only returns valid values for description types of 
	@c kTKDescriptionText. It returns invalid values for all other description types.
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionsFromItem:
@see extractDescriptionType:
@see extractDescriptionText:
@see isInterObjectReference
*/
- (NSString*) extractDescriptionText:(id) item;

/** Determines if the given reference is inter-object or member reference.￼

This method can be used to determine the type of the given reference. It should be
passed the reference obtained from the @c extractDescriptionReference:() method.￼ If
@c mil is passed, @c NO is returned.

@param reference The reference to check.
@return Returns @c YES if the given reference represents an inter-object reference,
	@c NO otherwise. Also returns @c NO if @c mil is passed as the parameter.
@see extractDescriptionReference:
*/
- (BOOL) isInterObjectReference:(NSString*) reference;

/** Determines if at least one of the given brief or detailed paragraphs is used or not.
 
If at least one paragraph from the given array contains some tekst, the method assumes
it is not empty. Note that all empty paragraphs are already removed from the cleaned 
source in previous steps, but some may still be present...

@param nodes The array returned from description parsing methods.
@return Returns @c YES if at least one paragraph contains some text.
@see extractBriefDescriptionFromItem:
@see extractBriefDescriptionsFromItem:
@see extractDetailDescriptionsFromItem:
@see extractDescriptionsFromItem:
*/
- (BOOL) isDescriptionUsed:(NSArray*) nodes;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Miscellaneous parsing helpers
//////////////////////////////////////////////////////////////////////////////////////////

/** Extracts the given sub item from the given item.

Note that this method always returns the first subitem if more than one exists.

@param item The item to extract from.
@param name The name of the subitem to extract.
@return Returns the given subitem or @c nil if doesn't exist.
@warning @b Important: This method is here because other methods from the category need 
	it. It should not be used by the subclasses and should be regarded as internal!
@see extractSubitemsFromItem:appendToArray:closeContainers:
*/
- (id) extractSubitemFromItem:(id) item
					 withName:(NSString*) name;

/** Extracts all sub items from the given item.￼

Note that this returns the whole hierarchy of sub-items in proper order.￼ Optionally,
this can also close all container sub-items.

@param item The item which subitems to extract.
@param array The array to which to append the items.
@param close If @c YES, all container sub-items are "closed", otherwise not.
@warning @b Important: This method is here because other methods from the category need
	it. It should not be used by the subclasses and should be regarded as internal!
@see extractSubitemFromItem:withName:
*/
- (void) extractSubitemsFromItem:(id) item
				   appendToArray:(NSMutableArray*) array
				 closeContainers:(BOOL) close;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper generation methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends the given string to the end of the given data, followed by a new line.

@param string The string to append before the new line.
@param data The data to append to.
@exception NSException Thrown if appending fails.
@see appendString:toData:
*/
- (void) appendLine:(NSString*) string toData:(NSMutableData*) data;

/** Appends the given string to the end of the given data.

@param string The string to append.
@param data The data to append to.
@exception NSException Thrown if appending fails.
@see appendLine:toData:
*/
- (void) appendString:(NSString*) string toData:(NSMutableData*) data;

@end
