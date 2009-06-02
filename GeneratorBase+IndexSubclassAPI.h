//
//  GeneratorBase+IndexSubclassAPI.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneratorBase.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines helper virtual methods for the @c GeneratorBase subclasses that help
index output generation.
*/
@interface GeneratorBase (IndexSubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass index file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any header text before the actual generation starts.￼

The message is sent from the @c outputDataForIndex() as the first message. It gives 
subclasses a chance to append data to the output before the actual output generation starts. 
After this message is sent, the rest of the messages are followed and as the last one,
@c appendIndexFooterToData:() is sent.

@param data ￼￼￼￼￼￼The data to append to. This is guaranteed to be non @c null.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see outputDataForIndex
@see appendIndexFooterToData:
*/
- (void) appendIndexHeaderToData:(NSMutableData*) data;

/** Appends any footer text after output generation ends.￼

The message is sent from the @c outputDataForIndex() as the last message. It 
gives subclasses a chance to append data to the output after the rest of the output is 
generated. This is ussually the place to "close" open tags or similar.

@param data ￼￼￼￼￼￼The data to append to. This is guaranteed to be non @c null.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see outputDataForIndex
@see appendIndexHeaderToData:
*/
- (void) appendIndexFooterToData:(NSMutableData*) data;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass index group handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any index group header text before the actual group items generation starts.￼

The message is sent from the @c outputDataForIndex() just before index group items are
generated. It gives subclasses a chance to append data to the output before the generation
for group items starts. After this message is sent, at least one 
@c appendIndexGroupItemToData:fromItem:type:index:() message is sent and then 
@c appendIndexGroupFooterToData:type:() is sent at the end.
 
The type identifies the type of the index group and can be one of the following:
- @c kTKIndexGroupClasses: This group will append all classes.
- @c kTKIndexGroupProtocols: This group will append all protocols.
- @c kTKIndexGroupCategories: This group will append all categories.

@param data ￼￼￼￼￼￼The data to append to. This is guaranteed to be non @c null.
@param type ￼￼￼￼￼￼The type of the index group.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see outputDataForIndex
@see appendIndexGroupItemToData:fromItem:index:type:
@see appendIndexGroupFooterToData:type:
*/
- (void) appendIndexGroupHeaderToData:(NSMutableData*) data
								 type:(int) type;

/** Appends any index group footer text after the group items generation ends.￼

The message is sent from the @c outputDataForIndex() as the last group generation message.
It gives subclasses a chance to append data to the output after the generation for index
group ends. This is ussually the place to "close" open tags or similar.

The type identifies the type of the index group and can be one of the following:
- @c kTKIndexGroupClasses: This group will append all classes.
- @c kTKIndexGroupProtocols: This group will append all protocols.
- @c kTKIndexGroupCategories: This group will append all categories.

@param data ￼￼￼￼￼￼The data to append to. This is guaranteed to be non @c null.
@param type The type of the index group.
@exception ￼￼￼￼￼NSException Thrown if appending fails.
@see outputDataForIndex
@see appendIndexGroupHeaderToData:type:
@see appendIndexGroupItemToData:fromItem:index:type:
*/
- (void) appendIndexGroupFooterToData:(NSMutableData*) data
								 type:(int) type;

/** ￼Appends the given index group item data.￼

This message is sent from @c outputDataForIndex() for each group member. The subclass 
should append the data for the given item. The subclass can get more information about 
the member by using the index member data methods from the @c GeneratorBase(IndexParsingAPI)
category.
 
The type identifies the type of the index group and can be one of the following:
- @c kTKIndexGroupClasses: This group will append all classes.
- @c kTKIndexGroupProtocols: This group will append all protocols.
- @c kTKIndexGroupCategories: This group will append all categories.
 
@param data The data to append to. This is guaranteed to be non @c null.
@param item The data item describing the given member.
@param index Zero based index of the member within the group.
@param type The type of the index group.
@exception NSException Thrown if appending fails.
@see outputDataForIndex
@see appendIndexGroupHeaderToData:type:
@see appendIndexGroupFooterToData:type:
*/
- (void) appendIndexGroupItemToData:(NSMutableData*) data
						   fromItem:(id) item
							  index:(int) index
							   type:(int) type;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns current index output title. */
@property(readonly) NSString* indexTitle;

/** Returns current index cleaned XML document. */
@property(readonly) NSXMLDocument* indexMarkup;

@end
