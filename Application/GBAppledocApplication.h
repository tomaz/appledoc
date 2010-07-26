//
//  GBAppledocApplication.h
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCliApplication.h"
#import "GBApplicationSettingsProviding.h"

/** The appledoc application handler. 
 
 This is the principal tool class. It represents the entry point for the application. The main promises of the class
 are parsing and validating of command line arguments and initiating documentation generation. Generation is divided
 into several distinct phases:
 
 1. Parsing data from source files: This is the initial phase where input directories and files are parsed into a
	memory representation (i.e. objects) suitable for subsequent handling. This is where the source code files are 
	parsed and validated for possible file or object-level incosistencies. This step is driven by `GBParser` class.
 
 2. Post-processing of the data parsed in the previous step: At this phase, we already have in-memory representation
	of all source code objects, so we can post-process and validate things such as links to other objects etc. We can
	also update the in-memory representation with this data and therefore prepare everything for the final phase. This
	step is driven by `GBProcessor` class.
 
 3. Generating output: This is the final phase where we use the in-memory data to generate output. This step is driven
	by `GBGenerator` class.
 */
@interface GBAppledocApplication : NSObject <GBApplicationSettingsProviding, DDCliApplicationDelegate>

@end
