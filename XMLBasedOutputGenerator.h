//
//  XMLBasedOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "OutputGenerator.h"

/** Defines different object info item types. */
enum TKGeneratorObjectInfoItemTypes
{
	kTKObjectInfoItemInherits,
	kTKObjectInfoItemConforms,
	kTKObjectInfoItemDeclared,
};

/** Defines different object main member group types. */
enum TKGeneratorObjectMemberTypes
{
	kTKObjectMemberTypeClass,
	kTKObjectMemberTypeInstance,
	kTKObjectMemberTypeProperty,
};

/** Defines different object member prototype item types. These values define the type
of the item which can either be value or parameter name. */
enum TKGeneratorObjectPrototypeTypes
{
	kTKObjectMemberPrototypeValue,
	kTKObjectMemberPrototypeParameter,
};

/** Defines different object common member section types. These are used mainly to
simplify the code and avoid repetition since many member sections use the same layout
for different types of sections. */
enum TKGeneratorObjectMemberSectionTypes
{
	kTKObjectMemberSectionParameters,
	kTKObjectMemberSectionExceptions,
};

/** Defines different index group types. These are used mainly to simplify the code and
 avoid repetition since all of the groups use the same layout. */
enum TKGeneratorIndexGroupTypes
{
	kTKIndexGroupClasses,
	kTKIndexGroupProtocols,
	kTKIndexGroupCategories,
};

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines the basics for a concrete @c OutputGenerator which is based on the
output produces by @c XMLOutputGenerator.

The main responsibility of this class is to hide the underlying XML handling from the
subclasses. Instead it delegates parsing of the underlying data by sending the subclass
messages for each detected data and by providing several utility methods that can be used 
to extract the data from the arguments. This unifies parsing for all subclasses and allows
one-point handling for each different value, so if XML structure changes one day, there
should be very small ammount of work for subclasses.

Each concrete subclass can convert three types of files - index, hierarchy and object files.
The subclass can only override the methods for generating output that makes sense for the 
implemented output type. The @c XMLBasedOutputGenerator overrides the 
@c generateSpecificOutput() in which it delegates the concrete output generation through 
the following messages:
- @c generateOutputForIndex() to generate the main index file,
- @c generateOutputForHierarchy() to generate the main hierarchy file and
- @c generateOutputForObject:() to generate the documentation for each individual object.
 
However the subclass should not override these, but instead override all associated
@c append______ methods (see the documentation for above mentioned methods for details).
The main responsibility of these entry points is to setup data and invoke parsing of the
associated XML structure which ends in @c append______ being sent. The subclass should
override these and handle the data as needed. To extract the usable information from
each append method, @c extract______ messages can be sent to the receiver. Additionaly,
subclasses should also handle the rest of the @c OutputGenerator tasks such as creation
and removal of output directories etc.
 
@warning @b Important: Note that @c outputGenerationStarting() is used to setup internal
	state, so in case subclass needs to override it, base implementation needs to be
	called!
*/
@interface XMLBasedOutputGenerator : OutputGenerator
{
	NSDictionary* objectData;
	NSXMLDocument* objectMarkup;
	NSXMLDocument* indexMarkup;
	NSXMLDocument* hierarchyMarkup;
	BOOL outputFileWasCreated;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates the output data for the given object data from the main database.

This message is sent from @c generateSpecificOutput() after the passed object data 
is stored in the class properties. The concrete subclasses that require full control over 
the generated data, can override this method and return the desired output. If overriden, 
the subclass can get the XML document through the @c objectMarkup property.
 
By default, this will send several higher level messages which can be overriden instead.
This is the recommended way of handling the output generation. The messages are sent in 
the following order:
- @c appendObjectHeaderToData:() 
- @c appendObjectInfoHeaderToData:() @a *
- @c appendObjectInfoItemToData:fromItems:index:type:() @a **
- @c appendObjectInfoFooterToData:() @a * 
- @c appendObjectOverviewToData:fromItem:() @a *
- @c appendObjectTasksHeaderToData:() @a *
- @c appendObjectTaskHeaderToData:fromItem:index:() @a **
- @c appendObjectTaskMemberToData:fromItem:index:() @a **
- @c appendObjectTaskFooterToData:fromItem:index:() @a **
- @c appendObjectTasksFooterToData:() @a * 
- @c appendObjectMembersHeaderToData:() @a *
- @c appendObjectMemberGroupHeaderToData:type:() @a **
- @c appendObjectMemberToData:fromItem:index:() @a **
- @c appendObjectMemberGroupFooterToData:type:() @a **
- @c appendObjectMembersFooterToData:() @a *
- @c appendObjectFooterToData:()
 
Note that only a subset of above messages may be sent for a particular object, depending
on the object data. Messages marked with @a * are optional, while messages marked with 
@a ** may additionaly be sent multiple times, for each corresponding item once.
 
After generation finishes, the corresponding file is saved to the proper location.

@param data The object @c NSDictionary from the main database.
@exception NSException Thrown if the given data is @c nil or generation fails.
@see generateOutputForIndex
@see generateOutputForHierarchy
*/
- (void) generateOutputForObject:(NSDictionary*) data;

/** Generates the output data for the main index.

This message is sent from @c generateSpecificOutput() after the objects generation
finishes. The concrete subclasses that require full control over the generated data, can
override this method and return the desired output. If overriden, the subclass can get 
the clean index XML data through the @c indexMarkup() property.
 
By default, this will send several higher level messages which can be overriden instead.
This is the recommended way of handling the output generation. The messages are sent in 
the following order:
- @c appendIndexHeaderToData:()
- @c appendIndexGroupHeaderToData:type:() **
- @c appendIndexGroupItemToData:fromItem:index:type:() **
- @c appendIndexGroupFooterToData:type:() **
- @c appendIndexFooterToData:()
 
Note that only a subset of above messages may be sent for a particular object, depending
on the object data. Messages marked with @a * are optional, while messages marked with 
@a ** may additionaly be sent multiple times, for each corresponding item once.

After generation finishes, the corresponding file is saved to the proper location.

@exception NSException Thrown if the generation fails.
@see generateOutputForObject:
@see generateOutputForHierarchy
*/
- (void) generateOutputForIndex;

/** Generates the output data from the data contained in the class properties.

This message is sent from @c generateSpecificOutput() after the objects and index
generation finishes. The concrete subclasses that require full control over the 
generated data, can override this method and return the desired output. If overriden, 
the subclass can get the clean hierarchy XML through the @c hierarchyMarkup() property.
 
By default, this will send several higher level messages which can be overriden instead.
This is the recommended way of handling the output generation. The messages are sent in 
the following order:
- @c appendHierarchyHeaderToData:()
- @c appendHierarchyGroupHeaderToData:() **
- @c appendHierarchyGroupItemToData:fromItem:index:() **
- @c appendHierarchyGroupFooterToData:() ** 
- @c appendHierarchyFooterToData:()
 
Note that only a subset of above messages may be sent for a particular object, depending
on the object data. Messages marked with @a * are optional, while messages marked with 
@a ** may additionaly be sent multiple times, for each corresponding item once.

@warning @b Important: Since objects hierarchy is tree-like structure with multiple levels,
	subclass should be able to have full control of when the children of a particular item
	are handled. The base class only automates the root objects notifications, while the
	subclass is responsible for sending @c generateHierarchyGroupChildrenToData:forItem:() 
	from within it's @c appendHierarchyGroupItemToData:fromItem:index:() override in order 
	to trigger the parsing of the children (if there are some). This deviates somehow from
	the rest of the output generation types. This actually starts recursive loop between
	@c generateHierarchyGroupChildrenToData:forItem:() and 
	@c appendHierarchyGroupItemToData:fromItem:index:(), however do not fear, since the 
	base class method will automatically stop when no more children are detected.
@exception NSException Thrown if the given @c data or saving to file fails.
@see generateOutputForObject:
@see generateOutputForIndex
*/
- (void) generateOutputForHierarchy;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the project name from command line. */
@property(readonly) NSString* projectName;

/** Returns the last updated date formatted in standard way.

Note that this always return formatted current system time.
*/
@property(readonly) NSString* lastUpdated;

/** Returns the status of output files generation.

This returns @c YES if at least one output file was generated within the last generation
run (i.e. between the @c outputGenerationStarting() and @c outputGenerationFinished() 
messages).
*/
@property(readonly) BOOL outputFileWasCreated;

@end
