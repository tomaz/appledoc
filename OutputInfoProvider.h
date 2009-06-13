//
//  OutputInfoProvider.h
//  appledoc
//
//  Created by Tomaz Kragelj on 12.6.09.
//  Copyright (C) 2009, Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** The @c OutputInfoProvider protocol defines methods that objects which need to
provide information about their output must implement.

The main argument for this interface is to decouple concrete @c OutputGenerator classes
from their dependent output generators. For example documentation set generator needs to
know the names and extensions used by the XHTML output generator. However to allow
arbitrary HTML output generator to be used with documentation set, the documentation set
output generator needs any object that conforms to @c OutputInfoProvider so that it
can get all required information it needs.
*/
@protocol OutputInfoProvider

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Output information providing
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the given object file name.￼￼

@param objectData The @c NSDictionary from main database representing the object data.
@return Returns the given object file name, including relative path from the base
	directory and extension.
@see outputIndexFilename
@see outputHierarchyFilename
@see outputFilesExtension
@see outputBasePath
*/
- (NSString*) outputObjectFilenameForObject:(NSDictionary*) objectData;

/** Returns the index file name.
 
@return Returns the index file name, including relative path from the base directory and
	extension.
@see outputObjectFilenameForObject:
@see outputHierarchyFilename
@see outputFilesExtension
@see outputBasePath
*/
- (NSString*) outputIndexFilename;

/** Returns the hierarchy file name.
 
@return Returns the hierarchy file name, including relative path from the base directory 
	and extension.
@see outputObjectFilenameForObject:
@see outputIndexFilename
@see outputFilesExtension
@see outputBasePath
*/
- (NSString*) outputHierarchyFilename;

/** Returns the output files extension.￼
 
@return Returns the output files extension.￼
@see outputObjectFilenameForObject:
@see outputIndexFilename
@see outputHierarchyFilename
@see outputBasePath
*/
- (NSString*) outputFilesExtension;

/** Returns the base path where ￼output files are generated.￼
 
This is full path to the base directory under which all files are generated.

@return Returns the base path where ￼output files are generated.￼
@see outputObjectFilenameForObject:
@see outputIndexFilename
@see outputHierarchyFilename
@see outputFilesExtension
*/
- (NSString*) outputBasePath;

@end
