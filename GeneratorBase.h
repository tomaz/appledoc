//
//  GeneratorBase.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.5.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommandLineParser;

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
/** Defines the basics for an output generator.

￼￼Output generators are objects that generate final output files from the intermediate
(cleaned) XML. Each type of supported output is implemented by a concrete subclass.
This class should be treated as abstract base class. It provides the stubs for the
output generation as well as several helper methods that the subclasses can use to
make their job easier.
 
Each concrete subclass can convert two types of files - the index files and object files.
The subclass can only override the methods for generating output that makes sense for the 
implemented output type. The clients send @c generateOutputForIndex:toFile:() to generate the
main index file and @c generateOutputForObject:toFile:() to generate the documentation for
individual objects.
 
In both cases, there are two options for generating output in the subclass. The first is
to use the default stubs. This means that the subclass should leave the layout and order
of creation to the base class and should override several methods which are sent during
the creation, depending the object that is being generated. The methods which fall into
this category are easily identified by their @c append prefix. This is the most common
and also the simplest way of getting the job done. However it limits the order in which
output elements are generated (of course the subclass can still use this way and generate
intermediate results which it can store to class variables and then use to generate the
complete output at the end of appending). If the subclass requires more control, it can
also override @c outputDataForObject() and/or @c outputDataForIndex() methods and handle 
the data in a completely custom way (@c outputDataForObject() message is sent from
@c generateOutputForObject:toFile:() which sets the class properties with the object data, so 
the subclass can use these to make it's life easier. Similarly, @c outputDataForIndex()
is sent from @c generateOutputForIndex()).
 
The class is designed so that the same instance can be re-used for generation of several
objects by simply sending the instance @c generateOutputForObject:toFile:() message and/or
@c generateOutputForIndex:toFile:() with the required data.
*/
@interface GeneratorBase : NSObject
{
	CommandLineParser* cmd;
	NSDictionary* objectData;
	NSDictionary* indexData;
	NSString* projectName;
	NSString* lastUpdated;
	BOOL wasFileCreated;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates the output￼ data from the given object data.

This is the main message that starts the whole generation for the given object. It copies 
the values from the given data to the properties and then sends the receiver 
@c outputDataForObject() message that triggers the object data parsing and in turn sends 
the receiver several messages that can be used to convert the data. When conversion
finishes, the data is saved to the given file.

@param data ￼￼￼￼￼￼An @c NSDictionary that describes the object for which output is generated.
@param filename The name of the file to save to.
@exception ￼￼￼￼￼NSException Thrown if the given @c data or @c filename is @c nil or empty or 
	output generation or saving to file fails.
@see outputDataForObject
@see generateOutputForIndex:toFile:()
*/
- (void) generateOutputForObject:(NSDictionary*) data
						  toFile:(NSString*) filename;

/** Generates the output￼ data from the given index data.

This is the main message that starts the whole generation for the given index. It copies 
the values from the given data to the properties and then sends the receiver 
@c outputDataForIndex() message that triggers the object data parsing and in turn sends 
the receiver several messages that can be used to convert the data. When conversion
finishes, the data is saved to the given file.


@param data ￼￼￼￼￼￼An @c NSDictionary that describes the object for which output is generated.
@param filename The name of the file to save to.
@exception ￼￼￼￼￼NSException Thrown if the given @c data or @c filename is @c nil or empty or 
	output generation or saving to file fails.
@see outputDataForIndex
@see generateOutputForObject:toFile:()
*/
- (void) generateOutputForIndex:(NSDictionary*) data
							toFile:(NSString*) filename;

/** Indicates that the output generation is starting.￼

This message is sent by the clients before any generation is started. It allows subclasses
to performs any custom "global" prerequisites handling ￼such as copying templates to known
locations or similar tasks.

@see generationFinished
@warning If the subclass overrides this method, it must call base implementation, or
	manually reset @c wasFileCreated(), otherwise it will not show proper value.
*/
- (void) generationStarting;

/** Indicates that the output generation has finished.￼

This message is sent by the clients after generation of all files is finished. It allows
the subclasses to perform any custom "global" handling such as copying stylesheets or
other similar tasks.
 
The subclass can use @c wasFileCreated() property value to determine if any file was
indeed created.
 
@see generationStarting
*/
- (void) generationFinished;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Subclass output generation
//////////////////////////////////////////////////////////////////////////////////////////

/** Generates the output data from the data contained in the class properties.￼

This message is sent from @c generateOutputForObject:toFile:() after the passed object data is 
stored in the class properties. The concrete subclasses that require full control over the 
generated data, can override this method and return the desired output. If overriden, the 
subclass can get the XML document through the @c objectMarkup property.
 
By default, this will send several higher level messages which can be overriden instead.
The messages are sent in the following order:
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
- @c appendObjectMemberGroupFooterToData:() @a **
- @c appendObjectMembersFooterToData:() @a *
 
- @c appendObjectFooterToData:()
 
Note that only a subset of above messages may be sent for a particular object, depending
on the object data. Messages marked with @a * are optional, while messages marked with 
@a ** may additionaly be sent multiple times, for each corresponding item once.

@return ￼￼￼￼Returns an autoreleased @c NSData containing generated output.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutputForObject:toFile:
@see outputDataForIndex
*/
- (NSData*) outputDataForObject;

/** Generates the output data from the data contained in the class properties.￼

This message is sent from @c generateOutputForObject:toFile:() after the passed object data is 
stored in the class properties. The concrete subclasses that require full control over the 
generated data, can override this method and return the desired output. If overriden, the 
subclass can get the XML document through the @c objectMarkup property.
 
By default, this will send several higher level messages which can be overriden instead.
The messages are sent in the following order:
- @c appendObjectHeaderToData:()
 
- @c appendObjectInfoHeaderToData:() @a *
- @c appendObjectInfoItemToData:fromItem:index:type:() @a **
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
- @c appendObjectMemberGroupFooterToData:() @a **
- @c appendObjectMembersFooterToData:() @a *
 
- @c appendObjectFooterToData:()
 
Note that only a subset of above messages may be sent for a particular object, depending
on the object data. Messages marked with @a * are optional, while messages marked with 
@a ** may additionaly be sent multiple times, for each corresponding item once.

@return ￼￼￼￼Returns an autoreleased @c NSData containing generated output.
@exception ￼￼￼￼￼NSException Thrown if generation fails.
@see generateOutputForIndex:toFile:
@see outputDataForObject
*/
- (NSData*) outputDataForIndex;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

/** Sets or returns the project name.￼

Clients should set this value prior to sending @c generateOutputForObject:toFile:() or
@c generateOutputForIndex:toFile:() messages. If the value is non @c nil and is not an empty 
string, the value can be used by the concrete generators to indicate the project name.
*/
@property(copy) NSString* projectName;

/** Sets or returns the last updated date.￼

Clients should set this value prior to sending @c generateOutputForObject:toFile:() or
@c generateOutputForIndex:toFile:() messages. If the value is non @c nil and is not an empty,
the value can be used by the concrete generators to indicate the time of the last update.
*/
@property(copy) NSString* lastUpdated;

/** Returns the status of output files generation.￼

This returns @c YES if at least one output file was generated within the last generation
run (i.e. between the @c generationStarting() and @c generationFinished() messages).
*/
@property(readonly) BOOL wasFileCreated;

@end
