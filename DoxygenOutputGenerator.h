//
//  DoxygenOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 11.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import "OutputGenerator.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Defines a concrete @c OutputGenerator which runs doxygen over the source files to
generate intermediate XML documentation.

The generator first checks if required doxygen configuration file exists. If not, it
creates it and updates it so that default options are all set. Then it extracts the
actual XML output directory path and other relevant values which can be changed by
the user after initial creation. When doxygen configuration file is processed, the
generator invokes doxygen so that it actually generates the output for us.
*/
@interface DoxygenOutputGenerator : OutputGenerator
{
	NSString* outputDirectory;
	NSString* outputRelativePath;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Doxygen handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates the doxygen configuration file if it doesn't exist yet.

This method checks if the desired doxygen file already exists or not. If not, it creates 
it by asking doxygen itself to generate the default file including comments so that later
manual tweaking is easier. Then it changes the default options so that XML output is
generated only. If the configuration file already exists, nothing happens.
 
This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.
 
@exception NSException Thrown if creation of the file fails.
@see updateDoxygenConfigFile
@see createDoxygenDocumentation
*/
- (void) createDoxygenConfigFile;

/** Updates the doxygen configuration file so that it contains proper options.

This method will check if configuration file exists or not. If it does, it will read it
and replace default options with new ones. If it finds at least one option changed,
it will not update the file to preserve any user customizations.
 
Note that this method will also parse the actual xml output path from the configuration
file and will set to the @c CommandLineParser, so that other generators can use it
later on.

This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.
 
@exception NSException Thrown if doxygen configuration file doesn't exist or cannot be
	parsed or changed.
@see createDoxygenConfigFile
@see createDoxygenDocumentation
*/
- (void) updateDoxygenConfigFile;

/** Creates the doxygen documentation by running the doxygen over it's configuration file.

This method will check if configuration file exists or not. If it does, it will run the
doxygen so that documentation is created. If the file doesn't exist, an exception will
be thrown.

This message is automatically sent from @c generateSpecificOutput() in the proper order.
It is not designed to be sent manually from the clients.
 
@exception NSException Thrown if doxygen configuration file doesn't exist or documentation
	creation fails (probably due to corrupted or invalid file).
@see createDoxygenConfigFile
@see updateDoxygenConfigFile
*/
- (void) createDoxygenDocumentation;

@end
