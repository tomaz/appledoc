//
//  GeneratorBase+ObjectSubclassAPI.h
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
objects output generation.
*/
@interface GeneratorBase (ObjectSubclassAPI)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass object file header and footer handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any header text before the actual generation starts.

The message is sent from the @c GeneratorBase::outputDataForObject() as the first message. 
It gives subclasses a chance to append data to the output before the actual output 
generation starts. After this message is sent, the rest of the messages are followed and 
as the last one, @c appendObjectFooterToData:() is sent.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectFooterToData:
*/
- (void) appendObjectHeaderToData:(NSMutableData*) data;

/** Appends any footer text after output generation ends.

The message is sent from the @c GeneratorBase::outputDataForObject() as the last message. It 
gives subclasses a chance to append data to the output after the rest of the output is 
generated. This is ussually the place to "close" open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectHeaderToData:
*/
- (void) appendObjectFooterToData:(NSMutableData*) data;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass object info handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any object info header text before the actual generation starts.

The message is sent from the @c GeneratorBase::outputDataForObject() just before object info 
items are generated. It gives subclasses a chance to append data to the output before the 
generation for secion items starts. After this message is sent, at least one 
@c appendObjectInfoItemToData:fromItems:index:type:() message is sent and then 
@c appendObjectInfoHeaderToData:() is sent at the end.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectInfoItemToData:fromItems:index:type:
@see appendObjectInfoFooterToData:
*/
- (void) appendObjectInfoHeaderToData:(NSMutableData*) data;

/** Appends any object info footer text after the object info items generation ends.

The message is sent from the @c GeneratorBase::outputDataForObject() as the last info
generation message. It gives subclasses a chance to append data to the output after the 
info items generation is finished. This is ussually the place to "close" open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectInfoHeaderToData:
@see appendObjectInfoItemToData:fromItems:index:type:
*/
- (void) appendObjectInfoFooterToData:(NSMutableData*) data;

/** Appends the given object info item data.

This message is sent from @c GeneratorBase::outputDataForObject() for each applicable object 
info item type. The subclass should append the data for the given item. The subclass can get 
more information about the object info item by investigating the given array which 
contains objects that can be used to query additional data for individual item.
 
The type identifies the type of the info item and can be one of the following:
- @c kTKInfoItemInherits: The @c nodes contain inherit from information. Only one node
	is in the list in most (all) cases.
- @c kTKInfoItemConforms: The @c nodes contain conforms to information. The nodes list may
	contain one or more protocols to which the object conforms.
- @c kTKInfoItemDeclared: The @c nodex contain declared in information. Only one node
	is in the list in most (all) cases.
 
@param data The data to append to. This is guaranteed to be non @c null.
@param items The array of info items instances describing individual items.
@param index Zero based index of the item within the info object info.
@param type The type of the item.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectInfoHeaderToData:
@see appendObjectInfoFooterToData:
*/
- (void) appendObjectInfoItemToData:(NSMutableData*) data
						  fromItems:(NSArray*) items
							  index:(int) index
							   type:(int) type;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass object overview handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends object overview description.

This message is sent from @c GeneratorBase::outputDataForObject() if the object has brief 
and or detailed documentation assigned. It gives subclasses a chance to append object overview 
from the gathered documentation. The given @c item contains brief and detailed object
description and can be treated as any other description item.

@param data The data to append to. This is guaranteed to be non @c null.
@param item The item that contains the brief and detailed description.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
*/
- (void) appendObjectOverviewToData:(NSMutableData*) data 
						   fromItem:(id) item;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass object tasks handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any tasks header before the actual tasks generation starts.

The message is sent from the @c GeneratorBase::outputDataForObject() if the object has at 
least one task defined. It gives subclasses a chance to append data to the output before 
any individual task handling is started. After this message is sent, each individual 
task is handled and when all tasks are done, @c appendObjectTasksFooterToData:() is sent.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectTaskHeaderToData:fromItem:index:
@see appendObjectTaskFooterToData:fromItem:index:
@see appendObjectTasksFooterToData:
*/
- (void) appendObjectTasksHeaderToData:(NSMutableData*) data;

/** Appends any tasks footer after sections generation ends.

The message is sent from the @c GeneratorBase::outputDataForObject() after all tasks have 
been processed. It gives subclasses a chance to append data to the output at that point. 
This is ussually the place to "close" tasks open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectTasksHeaderToData:
@see appendObjectTaskHeaderToData:fromItem:index:
@see appendObjectTaskMemberToData:fromItem:index:
@see appendObjectTaskFooterToData:fromItem:index:
*/
- (void) appendObjectTasksFooterToData:(NSMutableData*) data;

/** Appends an individual task header before the task members generation starts.

The message is sent from the @c GeneratorBase::outputDataForObject() for each task which 
has at least one member. It gives subclasses a chance to append data to the output before 
member handling for the given task starts.

@param data The data to append to. This is guaranteed to be non @c null.
@param item The item that contains the task description.
@param index Zero based index of the task.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectTasksHeaderToData:
@see appendObjectTaskMemberToData:fromItem:index:
@see appendObjectTaskFooterToData:fromItem:index:
@see appendObjectTasksFooterToData:
*/
- (void) appendObjectTaskHeaderToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index;

/** Appends an individual task footer after the task members generation ends.

The message is sent from the @c GeneratorBase::outputDataForObject() after all task members 
have been processed. It gives subclasses a chance to append data to the output at that 
point. This is ussually the place to "close" tasks open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@param item The item that contains the task description.
@param index Zero based index of the task.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectTasksHeaderToData:
@see appendObjectTaskHeaderToData:fromItem:index:
@see appendObjectTaskMemberToData:fromItem:index:
@see appendObjectTasksFooterToData:
*/
- (void) appendObjectTaskFooterToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index;

/** Appends a task member data.

This message is sent from the @c GeneratorBase::outputDataForObject() for each task member 
(class or instance method or property. Subclasses should append any desired data for the 
given member.

@param data The data to append to. This is guaranteed to be non @c null.
@param item The item that contains the task member description.
@param index Zero based index of the member within the task.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectTasksHeaderToData:
@see appendObjectTaskHeaderToData:fromItem:index:
@see appendObjectTaskFooterToData:fromItem:index:
@see appendObjectTasksFooterToData:
*/
- (void) appendObjectTaskMemberToData:(NSMutableData*) data
							 fromItem:(id) item
								index:(int) index;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass object member groups handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Appends any main members documentation header before the actual member generation starts.

The message is sent from the @c GeneratorBase::outputDataForObject() if the object has at least 
one main member group defined. It gives subclasses a chance to append data to the output 
before  any individual member handling is started. After this message is sent, each individual 
member group is handled and when all members are done, @c appendObjectMembersFooterToData:() is 
sent.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectMembersFooterToData:
@see appendObjectMemberGroupHeaderToData:type:
@see appendObjectMemberGroupFooterToData:type:
@see appendObjectMemberToData:fromItem:index:
*/
- (void) appendObjectMembersHeaderToData:(NSMutableData*) data;

/** Appends any main members documentation footer after members generation ends.

The message is sent from the @cGeneratorBase:: outputDataForObject() after all member groups 
have been processed. It gives subclasses a chance to append data to the output at that point. 
This is ussually the place to "close" sections open tags or similar.

@param data The data to append to. This is guaranteed to be non @c null.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectMembersHeaderToData:
@see appendObjectMemberGroupHeaderToData:type:
@see appendObjectMemberGroupFooterToData:type:
@see appendObjectMemberToData:fromItem:index:
*/
- (void) appendObjectMembersFooterToData:(NSMutableData*) data;

/** Appends member group header data.
 
This message is sent from @c GeneratorBase::outputDataForObject() for each main member 
documentation group. The group is specified with the @c type parameter and can be one of 
the following:
- @c kTKObjectMemberTypeClass: The group describes class members.
- @c kTKObjectMemberTypeInstance: The group describes instance members.
- @c kTKObjectMemberTypeProperty: The group describes properties.

Subclasses should append any desired data for the given group type. The message is only
sent if at least one member of the given type is documented for the object. After this
message one or more @c appendObjectMemberToData:fromItem:index:() messages are sent, one for
each documented member of the given group and after all members output is generated,
@c appendObjectMemberGroupHeaderToData:type:() is sent.

@param data The data to append to. This is guaranteed to be non @c null.
@param type The type of the group that is being described.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectMembersHeaderToData:
@see appendObjectMembersFooterToData:
@see appendObjectMemberToData:fromItem:index:
@see appendObjectMemberGroupFooterToData:type:
*/
- (void) appendObjectMemberGroupHeaderToData:(NSMutableData*) data 
										type:(int) type;

/** Appends member group footer data.

This message is sent from @c GeneratorBase::outputDataForObject() for each main member 
documentation group. The group is specified by the @c type parameter and can be one of 
the following:
- @c kTKObjectMemberTypeClass: The group describes class members.
- @c kTKObjectMemberTypeInstance: The group describes instance members.
- @c kTKObjectMemberTypeProperty: The group describes properties.
 
Subclasses should append any desired data for the given group type. In most cases this
is the place to close any open tags or similar. The message is only sent if the
corresponding @c appendObjectMemberGroupHeaderToData:type:() was sent.

@param data The data to append to. This is guaranteed to be non @c null.
@param type The type of the group that is being described.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectMembersHeaderToData:
@see appendObjectMembersFooterToData:
@see appendObjectMemberGroupHeaderToData:type:
@see appendObjectMemberToData:fromItem:index:
*/
- (void) appendObjectMemberGroupFooterToData:(NSMutableData*) data 
										type:(int) type;

/** Appends individual member full documentation data.

This message is sent from @c GeneratorBase::outputDataForObject() for each documented member. 
Subclasses should output the full documentation for the given member.

@param data The data to append to. This is guaranteed to be non @c null.
@param item The item that describes the member data.
@param index Zero based index of the member within the group.
@exception NSException Thrown if appending fails.
@see GeneratorBase::outputDataForObject
@see appendObjectMembersHeaderToData:
@see appendObjectMembersFooterToData:
@see appendObjectMemberGroupHeaderToData:type:
@see appendObjectMemberGroupFooterToData:type:
*/
- (void) appendObjectMemberToData:(NSMutableData*) data 
						 fromItem:(id) item 
							index:(int) index;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns current object output title. */
@property(readonly) NSString* objectTitle;

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
