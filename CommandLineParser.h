//
//  CommandLineParser.h
//  objcdoc
//
//  Created by Tomaz Kragelj on 12.4.09.
//  Copyright 2009 Tomaz Kragelj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTKVerboseLevelError	0
#define kTKVerboseLevelNormal	1
#define kTKVerboseLevelInfo		2
#define kTKVerboseLevelVerbose	3
#define kTKVerboseLevelDebug	4

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
/** This class parses the utility command line arguments and provides the values.
 
Since the class already knows how to interpret command line arguments, including verbose
levels, which are used throughout the whole application objects, the class is implemented
as a singleton.
*/
@interface CommandLineParser : NSObject
{
	NSMutableArray* commandLineArguments;
	NSMutableDictionary* parameters;
	NSString* globalTemplatesPath;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the shared instance of the class which can be used throughout the application.￼

To make the class as accessible for the rest of the application, it is implemented as a
singleton through @c sharedInstance(). Although nothing will prevent clients creating
additional instances, it is reccommended to use the singleton interface to prevent
possible problems.
*/
+ (CommandLineParser*) sharedInstance;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Parses the given command line arguments and set ups the object values.￼

This message must be sent to the class after construction before all the properties
can be used. It will parse and validate the given arguments. If any inconsistency is
detected, an exception will be thrown. After parsing all command line arguments, the
method checks if all required data is provided and returns @c YES if so. If not, it
returns @c NO which indicates that the user doesn't know how to use the utility and
@c printUsage() should probably be called.
 
Note that parsing code may be called as many times as needed. Eact time, the properties
are reset and then the given command line parsed.

@param argv ￼￼￼￼￼￼The array of zero terminated c strings.
@param argc ￼￼￼￼￼￼The number of items in the @c argv array.
@exception NSException Thrown if parsing fails.
*/
- (void) parseCommandLineArguments:(const char**) argv 
						   ofCount:(int) argc;

/** Outputs the utility usage to the standard output.￼
*/
- (void) printUsage;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////////////////////////

@property(readonly) NSString* commandLine;
@property(readonly) NSString* projectName;
@property(readonly) NSString* inputPath;
@property(readonly) NSString* outputPath;
@property(readonly) NSString* templatesPath;
@property(readonly) NSString* outputCleanXMLPath;
@property(readonly) NSString* outputCleanXHTMLPath;
@property(readonly) NSString* outputDocSetPath;
@property(readonly) NSString* outputDocSetContentsPath;
@property(readonly) NSString* outputDocSetResourcesPath;
@property(readonly) NSString* outputDocSetDocumentsPath;
@property(readonly) NSString* doxygenCommandLine;
@property(readonly) NSString* doxygenConfigFilename;
@property(readonly) NSString* docsetBundleID;
@property(readonly) NSString* docsetBundleFeed;
@property(readonly) NSString* docsetInstallPath;
@property(readonly) NSString* docsetSourcePlistPath;
@property(readonly) NSString* docsetutilCommandLine;
@property(readonly) int verboseLevel;
@property(readonly) BOOL removeTemporaryFiles;
@property(readonly) BOOL removeOutputFiles;
@property(readonly) BOOL removeEmptyParagraphs;
@property(readonly) BOOL mergeKnownCategoriesToClasses;
@property(readonly) BOOL createCleanXHTML;
@property(readonly) BOOL createDocSet;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Nondocumented properties
//////////////////////////////////////////////////////////////////////////////////////////

@property(readonly) BOOL emitUtilityOutput;

@end
