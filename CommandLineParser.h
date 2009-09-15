//
//  CommandLineParser.h
//  appledoc
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
#define kTKVerboseLevelFull		5

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
	NSString* outputDoxygenXMLPath;
	NSString* globalTemplatesPath;
}

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Initialization & disposal
//////////////////////////////////////////////////////////////////////////////////////////

/** Returns the shared instance of the class which can be used throughout the application.

To make the class as accessible for the rest of the application, it is implemented as a
singleton through @c sharedInstance(). Although nothing will prevent clients creating
additional instances, it is reccommended to use the singleton interface to prevent
possible problems.
*/
+ (CommandLineParser*) sharedInstance;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing handling
//////////////////////////////////////////////////////////////////////////////////////////

/** Parses the given command line arguments and set ups the object values.

This message must be sent to the class after construction before all the properties
can be used. It will parse and validate the given arguments. If any inconsistency is
detected, an exception will be thrown. After parsing all command line arguments, the
method checks if all required data is provided and returns @c YES if so. If not, it
returns @c NO which indicates that the user doesn't know how to use the utility and
@c printUsage() should probably be called.
 
Note that parsing code may be called as many times as needed. Eact time, the properties
are reset and then the given command line parsed.

@param argv The array of zero terminated c strings.
@param argc The number of items in the @c argv array.
@exception NSException Thrown if parsing fails.
@see printUsage
*/
- (void) parseCommandLineArguments:(const char**) argv 
						   ofCount:(int) argc;

/** Outputs the utility usage to the standard output.
 
@see parseCommandLineArguments:ofCount:
*/
- (void) printUsage;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - required
//////////////////////////////////////////////////////////////////////////////////////////

/** The command line path to the executable including full path. */
@property(readonly) NSString* commandLine;

/** Project name. */
@property(readonly) NSString* projectName;

/** The path to the source files. */
@property(readonly) NSString* inputPath;

/** The path to the output files (sub directories are created within this location). */
@property(readonly) NSString* outputPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - doxygen
//////////////////////////////////////////////////////////////////////////////////////////

/** The command line to the doxygen utility including full path. */
@property(readonly) NSString* doxygenCommandLine;

/** The path to the doxygen configuration file including full path. */
@property(readonly) NSString* doxygenConfigFilename;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - clean XML creation
//////////////////////////////////////////////////////////////////////////////////////////

/** If @c YES, class locations are fixed if (possibly) invalid location is detected. */
@property(readonly) BOOL fixClassLocations;

/** If @c YES, empty paragraphs should be removed from clean XML. */
@property(readonly) BOOL removeEmptyParagraphs;

/** If @c YES, documentation for categories to known classes should be merged to the 
class documentation. */
@property(readonly) BOOL mergeKnownCategoriesToClasses;

/** If @c YES, merged categories method sections should be preserved in the class.
 
@warning This option can create cluttered class documentation, so experiment to see if
	if works for you or not. */
@property(readonly) BOOL keepMergedCategorySections;

/** The template for creating references to members of another objects.
 
This is used to generate the actual reference name and is visible on the final output. */
@property(readonly) NSString* objectReferenceTemplate;

/** The template for creating references to members of the same object.
 
This is used to generate the actual reference name and is visible on the final output. */
@property(readonly) NSString* memberReferenceTemplate;

/** The template for formatting date/time strings. */
@property(readonly) NSString* dateTimeTemplate;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - clean output creation
//////////////////////////////////////////////////////////////////////////////////////////

/** If @c YES, clean XHTML documentation is created. */
@property(readonly) BOOL createCleanXHTML;

/** If @c YES, documentation set is created.
 
Note That @c createCleanXHTML() is a prerequisite for documentation set. */
@property(readonly) BOOL createDocSet;

/** If @c YES, Markdown documentaiton is created. */
@property(readonly) BOOL createMarkdown;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - XHTML output creation
//////////////////////////////////////////////////////////////////////////////////////////

/** If @c YES, use bordered XHTML example sections which results in more Apple like
documentation. */
@property(readonly) BOOL xhtmlUseBorderedExamples;

/** If @c YES, use bordered XHTML warning sections which results in more Apple like
documentation. */
@property(readonly) BOOL xhtmlUseBorderedWarnings;

/** If @c YES, use bordered XHTML bug sections which results in more Apple like
documentation. */
@property(readonly) BOOL xhtmlUseBorderedBugs;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - documentation set creation
//////////////////////////////////////////////////////////////////////////////////////////

/** The documentation set unique bundle ID. */
@property(assign) NSString* docsetBundleID;

/** The documentation set bundle feed which is displayed in the Xcode documentation window. */
@property(assign) NSString* docsetBundleFeed;

/** The documentation set source plist which contains identification and description. */
@property(readonly) NSString* docsetSourcePlistPath;

/** The @c docsetutil command line including full path. */
@property(readonly) NSString* docsetutilCommandLine;

/** The documentation set installation path.
 
This should be set to one of the known locations which Xcode searches. By default it is
set to user's documentation set directory. */
@property(readonly) NSString* docsetInstallPath;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - Markdown creation
//////////////////////////////////////////////////////////////////////////////////////////

/** If @c YES, object files links are created using reference style, otherwise inline
links are created. */
@property(readonly) BOOL markdownReferenceStyleLinks;

/** The maximum number of chars to use in one line.

This is the desired maximum line length.
*/
@property(readonly) int markdownLineLength;

/** The minimum number of chars in the line before considering wrapping.

This value controls line wrapping when adding non-wrappable phrases. It works in
pair with @c markdownLineLength() and @c markdownLineWrapMargin().
 
If the line has less chars than this value, a non-wrappable phrase is still appended if
the total line length including the phrase is below the sum of @c markdownLineLength() and
@c markdownLineWrapMargin().
 
@see markdownLineLength
*/
@property(readonly) int markdownLineWrapThreshold;

/** The maximum number of chars to use in one line.
 
This value controls line wrapping when adding non-wrappable phrases. It works in
pair with @c markdownLineLength() and @c markdownLineWrapThreshold().

If the line length is below or equal to the threshold, the phrase is added to it even if
the new line length is over the @c markdownLineLength() however below the given margin.

@see markdownLineLength
*/
@property(readonly) int markdownLineWrapMargin;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - miscellaneous
//////////////////////////////////////////////////////////////////////////////////////////

/** The path to the template files and global options.
 
This is automatically determined by checking the known locations which are (in order of
preference):
- ~/.appledoc
- ~/Application Support/appledoc */
@property(readonly) NSString* templatesPath;

/** If @c YES, temporary files are removed after generation.
 
This will effectively remove all but the "last" generated files. Which files will be
removed it depends on what is the desired output. If this is one of the clean outputs,
all doxygen and clean XML files will be removed. If this is documentation set, the
clean HTML files will be removed too (other final output files will remain if chosen). */
@property(readonly) BOOL cleanTempFilesAfterBuild;

/** If @c YES, the @c outputPath() is deleted before starting processing.
 
This is important because otherwise deleted or renamed files will remain in the final
documentation.
@ warning Be careful when using this option - it will remove the @c outputPath() directory
	too, so if you keep any files which are not automatically generated there (should not
	really!), such as source files or plists etc., these will also be removed! */
@property(readonly) BOOL cleanOutputFilesBeforeBuild;

/** The desired verbose level.
 
This is used by the log macros, so in most cases, you'll not use it directly in code. */
@property(readonly) int verboseLevel;

//////////////////////////////////////////////////////////////////////////////////////////
/// @name Properties - "undocumented"
//////////////////////////////////////////////////////////////////////////////////////////

/** This is used to show or hide the output from the external utilities such as @c doxygen
and @c docsetutil. */
@property(readonly) BOOL emitUtilityOutput;

/** Generator name and version. */
@property(readonly) NSString* generator;

/** The version of appledoc. */
@property(readonly) NSString* version;

@end
