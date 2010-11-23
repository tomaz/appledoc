//
//  GBApplicationSettingsProviding.h
//  appledoc
//
//  Created by Tomaz Kragelj on 23.7.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBCommentComponentsProvider.h"
#import "GBApplicationStringsProvider.h"

@class GBModelBase;

/** Defines the requirements for application-level settings providers.
 
 Application-level settings providers provide application-wide settings and properties that affect application handling.
 */
@protocol GBApplicationSettingsProviding

///---------------------------------------------------------------------------------------
/// @name Template paths handling
///---------------------------------------------------------------------------------------

/** The base path to template files used for generating various output files. */
@property (copy) NSString *templatesPath;

/** The path to the CSS template file, relative from class html files. 
 
 @see cssCategoryTemplatePath
 @see cssProtocolTemplatePath
 @see cssIndexTemplatePath
 */
@property (readonly) NSString *cssClassTemplatePath;

/** The path to the CSS template file, relative from category html files.
 
 @see cssClassTemplatePath
 @see cssProtocolTemplatePath
 @see cssIndexTemplatePath
 */
@property (readonly) NSString *cssCategoryTemplatePath;

/** The path to the CSS template file, relative from protocol html files.
 
 @see cssClassTemplatePath
 @see cssCategoryTemplatePath
 @see cssIndexTemplatePath
 */
@property (readonly) NSString *cssProtocolTemplatePath;

/** The path to the CSS template file, relative from index html files.
 
 @see cssClassTemplatePath
 @see cssCategoryTemplatePath
 @see cssProtocolTemplatePath
 */
@property (readonly) NSString *cssIndexTemplatePath;

///---------------------------------------------------------------------------------------
/// @name Output paths handling
///---------------------------------------------------------------------------------------

/** The base path of the generated files. */
@property (copy) NSString *outputPath;

/** The base path of the HTML generated files.
 
 This value depends on `outputPath` and is automatically calculated.
 
 @see htmlOutputPathForObject:
 @see htmlOutputPathForIndex
 @see outputPath
 */
@property (readonly) NSString *htmlOutputPath;

/** Returns file name including full path for HTML file representing the given top-level object.
 
 This works for any top-level object: class, category or protocol. The path is automatically determined regarding to the object class.
 
 @param object The object for which to return the path.
 @return Returns the path.
 @exception NSException Thrown if the given object is `nil` or not top-level object.
 @see htmlOutputPathForIndex
 @see htmlOutputPath
 */
- (NSString *)htmlOutputPathForObject:(GBModelBase *)object;

/** Returns file name including full path for HTML file representing the main index.
 
 @return Returns the path.
 @see htmlOutputPathForObject:
 @see htmlOutputPath
 */
- (NSString *)htmlOutputPathForIndex;

/** Returns HTML reference name for the given object.
 
 This should only be used for creating anchors that need to be referenced from other parts of the same HTML file. The method works for top-level objects as well as their members.
 
 @param object The object for which to return reference name.
 @return Returns the reference name of the object.
 @exception NSException Thrown if the given object is `nil`.
 @see htmlReferenceForObject:fromSource:
 */
- (NSString *)htmlReferenceNameForObject:(GBModelBase *)object;

/** Returns relative HTML reference to the given object from the context of the given source object.
 
 This is useful for generating hrefs from one object HTML file to another. This is the swiss army knife king of a method for all hrefs generation. It works for any kind of links:
 
 - Index to top-level object (if source is `nil`).
 - Index to a member of a top-level object (if source is `nil`).
 - Top-level object to same top-level object.
 - Top-level object to a different top-level object.
 - Top-level object to one of it's members.
 - Member object to it's top-level object.
 - Member object to another top-level object.
 - Member object to another member of the same top-level object.
 - Member object to a member of another top-level object.
 
 @param object The object for which to generate the reference to.
 @param source The source object from which to generate the reference from or `nil` for index to object reference.
 @return Returns the reference string.
 @exception NSException Thrown if object is `nil`.
 @see htmlReferenceNameForObject:
 */
- (NSString *)htmlReferenceForObject:(GBModelBase *)object fromSource:(GBModelBase *)source;

///---------------------------------------------------------------------------------------
/// @name Other paths handling
///---------------------------------------------------------------------------------------

/** The list of all full or partial paths to be ignored. 
 
 It's recommended to check if a path string ends with any of the given paths before processing it. This should catch directory and file names properly as directories are processed first.
 */
@property (retain) NSMutableArray *ignoredPaths;

///---------------------------------------------------------------------------------------
/// @name Helper classes
///---------------------------------------------------------------------------------------

/** Returns the `GBCommentComponentsProvider` object that identifies comment components. */
@property (retain) GBCommentComponentsProvider *commentComponents;

/** Returns the `GBApplicationStringsProvider` object that specifies all string templates used for output generation. */
@property (retain) GBApplicationStringsProvider *stringTemplates;

@end
