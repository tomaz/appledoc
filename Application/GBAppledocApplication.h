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
 
 This is the principal tool class. It represents the entry point for the application. The main promises of the class are parsing and validating of command line arguments and initiating documentation generation. Generation is divided into several distinct phases:
 
 1. Parsing data from source files: This is the initial phase where input directories and files are parsed into a memory representation (i.e. objects) suitable for subsequent handling. This is where the source code files are  parsed and validated for possible file or object-level incosistencies. This step is driven by `GBParser` class. 
 2. Post-processing of the data parsed in the previous step: At this phase, we already have in-memory representation of all source code objects, so we can post-process and validate things such as links to other objects etc. We can also update in-memory representation with this data and therefore prepare everything for the final phase. This step is driven by `GBProcessor` class.
 3. Generating output: This is the final phase where we use in-memory data to generate output. This step is driven by `GBGenerator` class.
 
 @warning *Implementation details:* To be able to properly apply all levels of settings - factory defaults, global settings and command line arguments - we can't solely rely on `DDCli` for parsing command line args. As the user can supply templates path from command line (instead of using one of the  default paths), we need to pre-parse command line arguments for templates switches. The last one found is then used to read global settings. This solves proper settings inheritance up to global settings level. Then `DDCli` is used to parse the arguments which effectively overrides all current settings with command line values. This needs to be done to compensate the way `DDCli` works - using KVC's `setValue:forKey:` for any command line switch detected. This works well for most cases, but as we need to get global templates first we need to compensate a bit. Although there are several possible solutions (the simplest forcing the user to pass templates switch before any other for example), I chose pre-parsing one as it seemed the most effective.
 */
@interface GBAppledocApplication : NSObject <DDCliApplicationDelegate>

@end
