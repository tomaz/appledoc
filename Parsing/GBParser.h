//
//  GBParser.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Handles loading class data from source files.
 
 This is the first phase of appledoc generation process. It walks the given directory hierarchy and loads source files data into memory structure prepared for next phases.
 */
@interface GBParser : NSObject

///---------------------------------------------------------------------------------------
/// @name ￼Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased parser that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)parserWithSettingsProvider:(id)settingsProvider;

/** Initializes the parser to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Parsing handling
///---------------------------------------------------------------------------------------

/** Scans the given array of paths and parses all code files into in-memory objects.
 
 This is the main method for source code parsing. It is intended to be invoked from the top level application code. It accepts an array of paths - either directories or file names - and parses them for code. If it detects an object within any file, it's data is parsed into in-memory representation suited for further processing. Parsed data is registered to the given `GBStore`.
 
 If any kind of inconsistency is detected in source code, a warning is logged and parsing continues. This allows us to extract as much information as possible, while ignoring problems.
 
 @warning *Note:* The method expects the given array contains `NSString`s representing existing directory or file names. The method itself doesn't validate this and may result in unpredictable behavior in case an invalid path is passed in. The paths don't have to be standardized, expanded or similar though.
 
 @param paths An array of strings representing paths to parse.
 @param store The store to add objects to.
 @exception NSException Thrown if a serious problem is detected which prevents us from parsing.
 @see parseDocumentsFromPaths:toStore:
 @see parseCustomDocumentFromPath:toStore:
 */
- (void)parseObjectsFromPaths:(NSArray *)paths toStore:(id)store;

/** Scans the given array of paths and parses all static document files into in-memory objects.
 
 This is the main method for static documents parsing. It is intended to be invoked from the top level application code. Is accepts an array of paths - either directories or file names - and parses them for static documents requiring post processing. If it detects such a document, it's contents are loaded into in-memory representation suited for furhter processing. Parsed data is registered to the given `GBStore`. If the document is empty, a warning is issued, but it's still registered; the result is an empty html file generated at output path.
 
 @warning *Note:* The method expects the given array contains `NSString`s representing existing directorry or file names. The method itself doesn't validate this and may result in unpredictable behavior in case an invalid path is passed in. The paths don't have to be standardized, expanded or similar though.
 
 @param paths An array of strings representing paths to parse.
 @param store The store to add objects to.
 @exception NSException Thrown if a serious problem is detected which prevents us from parsing.
 @see parseObjectsFromPaths:toStore:
 @see parseCustomDocumentFromPath:outputSubpath:key:toStore:
 */
- (void)parseDocumentsFromPaths:(NSArray *)paths toStore:(id)store;

/** Scans the given file and parses it as custom static document files into in-memory objects.
 
 Custom static documents are not standalone documents, but rather fractions of documents used for injection into other parts. For example: main index file documentation. This is the main method for these documents parsing. It is intended to be invoked from the top level application code. Is accepts a path to a filename and parses it the same way as normal static documents. Parsed data is registered to the given `GBStore`, each document using it's document filename without extension as the key. If the document is empty, a warning is issued, and the document is not registered.
 
 @param path The string containing filename and path to the document.
 @param outputPath The subpath relative to output path the object will be saved to.
 @param store The store to add objects to.
 @exception NSException Thrown if a serious problem is detected which prevents us from parsing.
 @see parseObjectsFromPaths:toStore:
 @see parseDocumentsFromPath:toStore:
 */
- (void)parseCustomDocumentFromPath:(NSString *)path outputSubpath:(NSString *)subpath key:(id)key toStore:(id)store;

@end
