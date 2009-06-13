//
//  OutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputProcessing.h"
#import "OutputInfoProvider.h"
#import "Constants.h"

@class CommandLineParser;

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines the basics for an output generator.

Output generators are objects that generate final output from intermediate files. Each 
type of supported output is implemented by a concrete subclass. This class should be 
treated as abstract base class. It provides the stubs for the output generation which
should be overriden by subclasses to implement the required functionality. Output 
generators conform to @c OutputProcessing and @c OutputInfoProvider formal protocols.
The @c OutputProcessing protocol is fully implemented, however the subclasses need to
override @c OutputInfoProvider::outputFilesExtension() and return proper value. Default
implementation returns empty string. The rest of the @c OutputInfoProvider methods should
generally be correctly implemented by the base class though.
 
Additionally, output generators also support tree-like generation of dependent generators.
This allows simple handling of dependent generation and eliminates the worry of when to
start certain dependent generator, when to remove temporary files etc. Dependent
generators must be registered prior than starting the actual generation. Registration is
performed by sending the receiver @c registerDependentGenerator:() message. Note that
clients are responsible for setting up dependencies, @c OutputGenerator objects then
handle all dependent generators at proper time.
 
@c OutputGenerator is an abstract base class. Concrete subclasses should implement their
specifics within the following overrides:
- @c outputGenerationStarting()
- @c outputGenerationFinished()
- @c generateSpecificOutput(): concrete subclasses should override this method and
	generate their specific output based on their promise. This message is sent from 
	@c generateOutput() which takes care of handling dependencies and directories 
	creation and removal among other things. So in general, subclasses should not 
	override @c generateOutput().
- @c createOutputDirectories()
- @c removeOutputDirectories()
 
Note that the @c OutputGenerator base class provides some helper variables to prevent
repetition and allow less cluttered code in the concrete subclasses. These include:
- @c manager: Set to the @c NSFileManager::defaultManager().
- @c cmd: Set to the @c CommandLineParser::sharedInstance().
- @c database: Set to the main objects database (set through the @c initWithDatabase:).
*/
@interface OutputGenerator : NSObject <OutputProcessing, OutputInfoProvider>
{
	CommandLineParser* cmd;
	NSFileManager* manager;
	NSMutableDictionary* database;
	NSMutableArray* dependentGenerators;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

/** Initializes the output generator.￼

This is the designated initializer. It maps the main objects database so it is accessible
for subclasses.

@param data The main database of objects which is used for creating output. The value is
	retained by the initializer, so all instances should be released when no longer used.
@return Returns initialized object or @c nil if initialization fails.
@exception NSException Thrown if the given database is @c nil or initialization fails.
@warning @b Important: Note that the some concrete subclasses actually create the data
	in the database, while others only use it. Therefore it is important that the 
	generation is invoked in the proper order. This is one of the points where clients
	should be aware of the proper order of creation and how different output generator
	subclasses are linked together.
*/
- (id) initWithDatabase:(NSMutableDictionary*) data;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Dependencies handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Registers the given dependent generator and adds it to the end of the dependent
generators list.￼

After dependent generator is registered, it is automaticallty handled, so clients don't
have to manually invoke it's output generation. Furthermore, removal of temporary files
is also automatically handled at proper time. Note that the given generator may in turn
have more dependent generators registered - output generation recursively invokes
generation in proper order. At this point, generators cannot be unregistered!
 
Note that all dependent generators must be registered before generating the output for
the receiver (i.e. before sending @c generateOutput() message).

@param generator The @c OutputProcessing subclass which depends on this generator.
@exception NSException Thrown if the given @c generator is @c nil.
*/
- (void) registerDependentGenerator:(id<OutputProcessing>) generator;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Output generation entry points
//////////////////////////////////////////////////////////////////////////////////////////

/** Notifies output generator that generation is starting.￼
 
This message is sent after previous output generator finishes but before the concrete
output generator starts processing the data. Subclasss can use it to setup initial 
values if for example.￼ When the receiver returns from the method, @c generateOutput()
is sent, followed by @c outputGenerationFinished().

@warning @c Important: Note that implementors
@see outputGenerationFinished
@see generateSpecificOutput
*/
- (void) outputGenerationStarting;

/** Notifies output generator that generation is finished.￼

This message is sent after the concrete output generator processing ends but before
next generator starts processing the data. Subclasss can use it to cleanup after
processing or to perform final tasks which depend on the processing results.

@exception NSException Thrown if errors are detected while finalizing output generation.
@see outputGenerationStarting
@see generateSpecificOutput
*/
- (void) outputGenerationFinished;

/** Notifies concrete output generator subclass to start processing the data and 
generate output.

This message is sent after @c createOutputDirectories() and @c outputGenerationStarting().
The concrete subclass should only handle it's specific output generation. After the
subclass returns, @c outputGenerationFinished() is sent. If any dependent generator is 
assigned, their output generation is issued afterwards. And when all dependent generators 
finish, @c removeOutputDirectories() is sent if temporary files should be removed.

@exception NSException Thrown if output generation fails.
@see outputGenerationStarting
@see outputGenerationFinished
*/
- (void) generateSpecificOutput;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Output directories handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates all required output directories.￼

This message is sent before any output generation begins if the subclass returns @ YES
from @c isOutputGenerationEnabled(). Subclasses should create all directories they require. 
If any of the required directories already exists, the subclass should decide on whether 
it should delete it or skip it. In most cases, the directory is left as is. If the directory 
contains files, the subclass should again decide whether it should remove these or 
leave them. Again, in most cases the files can be left as they are.
 
Default implementation creates the path returned from @c outputBasePath() and all
default subdirectories: @c Classes, @c Categories and @c Protocols. Subclasses that need
to create additional directories or don't want to use default ones, should override
and create all required directories themselves.

@exception NSException Thrown if directories creation fails.
@see removeOutputDirectories
*/
- (void) createOutputDirectories;

/** Removes all output directories and files.￼

This message is sent after all concrete output generators finish their jobs if temporary
files should be removed or before generation starts if clean run is desired. Subclasses 
should remove all generated directories and files. Note that this message is only sent
if @c createOutputDirectories() was sent at the start of the generation.
 
Default implementation removes the directory at the path returned from @c outputBasePath().
Subclasses that need to remove additional directories should override and remove all
directories created in @c createOutputDirectories(). This should be vary rare though.

@exception NSException Thrown if removing directories or files fails.
@see createOutputDirectories
*/
- (void) removeOutputDirectories;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Helper methods
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates a new @c NSString by replacing path placeholders in the given template path.￼￼

@param path The template path in which to replace placeholders.
@return Returns an autoreleased @c NSString containing correct path.
*/
- (NSString*) pathByReplacingTemplatePlaceholdersInPath:(NSString*) path;


@end