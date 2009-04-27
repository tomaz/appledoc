//
//  DoxygenConverter+Doxygen.h
//  objcdoc
//
//  Created by Tomaz Kragelj on 17.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoxygenConverter.h"

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** Implemented doxygen related functionality for @c DoxygenConverter class.

￼￼This category handles doxygen configuration file creation, updating default parameters
with user specified ones and running the doxygen utility itself.
*/
@interface DoxygenConverter (Doxygen)

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Doxygen handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Creates the doxygen configuration file if it doesn't exist yet.￼

This method will check if the desired doxygen file already exists or not. If not, it will
create it by asking doxygen itself to generate the default file. Then it will change all
options as necessary.
 
This message is automaticaly sent from @c DoxygenConverter::convert() in the proper order.

@exception ￼￼￼￼￼NSException Thrown if creation of the file fails.
@see updateDoxygenConfigFile
@see createDoxygenDocumentation
*/
- (void) createDoxygenConfigFile;

/** Updates the doxygen configuration file so that it contains proper options.￼

This method will check if configuration file exists or not. If it does, it will read it
and replace default options with new ones. If it finds at least one option changed,
it will not update the file to preserve any user customizations.
 
Note that this method will also remember the xml output path, so that we can use it
later on.

This message is automaticaly sent from @c DoxygenConverter::convert() in the proper order.

@exception ￼￼￼￼￼NSException Thrown if doxygen configuration file doesn't exist or cannot be
	parsed or changed.
@see createDoxygenConfigFile
@see createDoxygenDocumentation
*/
- (void) updateDoxygenConfigFile;

/** Creates the doxygen documentation by running the doxygen over it's configuration file.￼

This method will check if configuration file exists or not. If it does, it will run the
doxygen so that documentation is created. If the file doesn't exist, an exception will
be thrown.

This message is automaticaly sent from @c DoxygenConverter::convert() in the proper order.

@exception ￼￼￼￼￼NSException Thrown if doxygen configuration file doesn't exist or documentation
	creation fails (probably due to corrupted or invalid file).
@see createDoxygenConfigFile
@see updateDoxygenConfigFile
*/
- (void) createDoxygenDocumentation;

@end
