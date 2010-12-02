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
/// @name Behavior handling
///---------------------------------------------------------------------------------------

/* Indicates whether HTML files should be generated or not. If YES, HTML files are generated in `outputPath` from parsed and processed data. 
 */
@property (assign) BOOL createHTML;

/** Specifies whether documentation set should be created from the HTML files. If YES, HTML files from html subdirectory in `outputPath` are moved to proper subdirectory within docset output files, then helper files are generated from parsed data. Documentation set files are also indexed. If not, HTML files are left in the output path.
 */
@property (assign) BOOL createDocSet;

/** Specifies whether the documentation set should be installed or not. If YES, temporary files used for indexing and removed, then documentation set bundle is created from the files from docset output path and is moved to `docsetInstallPath`. If not, all documentation set files are left in output path.
 */
@property (assign) BOOL installDocSet;

///---------------------------------------------------------------------------------------
/// @name Project values handling
///---------------------------------------------------------------------------------------

/** Human readable name of the project. */
@property (copy) NSString *projectName;

/** Human readable name of the project company. */
@property (copy) NSString *projectCompany;

/** Human readable version of the project. */
@property (copy) NSString *projectVersion;

///---------------------------------------------------------------------------------------
/// @name Documentation set handling
///---------------------------------------------------------------------------------------

/** Documentation set bundle identifier. */
@property (copy) NSString *docsetBundleIdentifier;

/** Documentation set bundle name. */
@property (copy) NSString *docsetBundleName;

/** Documentation set certificate issuer. */
@property (copy) NSString *docsetCertificateIssuer;

/** Documentation set certificate signer. */
@property (copy) NSString *docsetCertificateSigner;

/** Documentation set description. */
@property (copy) NSString *docsetDescription;

/** Documentation set fallback URL. */
@property (copy) NSString *docsetFallbackURL;

/** Documentation set feed name. */
@property (copy) NSString *docsetFeedName;

/** Documentation set feed URL. */
@property (copy) NSString *docsetFeedURL;

/** Documentation set minimum Xcode version. */
@property (copy) NSString *docsetMinimumXcodeVersion;

/** Documentation set platform family. */
@property (copy) NSString *docsetPlatformFamily;

/** Documentation set publisher identifier. */
@property (copy) NSString *docsetPublisherIdentifier;

/** Documentation set publisher name. */
@property (copy) NSString *docsetPublisherName;

/** Documentation set human readble copyright message. */
@property (copy) NSString *docsetCopyrightMessage;

///---------------------------------------------------------------------------------------
/// @name Paths handling
///---------------------------------------------------------------------------------------

/** The base path to template files used for generating various output files. */
@property (copy) NSString *templatesPath;

/** The base path of the generated files. */
@property (copy) NSString *outputPath;

/** The path to which documentation set is to be installed. */
@property (copy) NSString *docsetInstallPath;

/** The list of all full or partial paths to be ignored. 
 
 It's recommended to check if a path string ends with any of the given paths before processing it. This should catch directory and file names properly as directories are processed first.
 */
@property (retain) NSMutableArray *ignoredPaths;

///---------------------------------------------------------------------------------------
/// @name Application-wide HTML helpers
///---------------------------------------------------------------------------------------

/** Returns HTML reference name for the given object.
 
 This should only be used for creating anchors that need to be referenced from other parts of the same HTML file. The method works for top-level objects as well as their members.
 
 @param object The object for which to return reference name.
 @return Returns the reference name of the object.
 @exception NSException Thrown if the given object is `nil`.
 @see htmlReferenceForObject:fromSource:
 @see htmlReferenceForObjectFromIndex:
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
 @see htmlReferenceForObjectFromIndex:
 @see htmlReferenceNameForObject:
 */
- (NSString *)htmlReferenceForObject:(GBModelBase *)object fromSource:(GBModelBase *)source;

/** Returns relative HTML reference to the given object from the context of index file.
 
 This is simply a helper method for `htmlReferenceForObject:fromSource:`, passing the given object as object parameter and `nil` as source.
 
 @pram object The object for which to generate the reference to.
 @return Returns the reference string.
 @exception NSException Thrown if object is `nil`.
 @see htmlReferenceForObject:fromSource:
 @see htmlReferenceNameForObject:
 */
- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object;

/** The file extension for html files.
 */
@property (readonly) NSString *htmlExtension;

///---------------------------------------------------------------------------------------
/// @name Helper methods
///---------------------------------------------------------------------------------------

/** Replaces all occurences of placeholder strings in all related values of the receiver.
 
 This message should be sent once all the values have been set. It is a convenience method that prepares all values that can use placeholder strings. From this point on, the rest of the application can simply use properties to get final values instead of sending `stringByReplacingOccurencesOfPlaceholdersInString:` all the time.
 
 Note that `stringByReplacingOccurencesOfPlaceholdersInString:` is still available for cases where placeholder strings may be used elsewhere (template files for example).
 
 @see stringByReplacingOccurencesOfPlaceholdersInString:
 */
- (void)replaceAllOccurencesOfPlaceholderStringsInSettingsValues;

/** Replaces all placeholders occurences in the given string.
 
 This method provides application-wide string placeholders replacement functionality. It replaces all known placeholders with actual values from the receiver. Placeholders are identified by a dollar mark, followed by placeholder name. The following placeholders are supported (note that case is important!):
 
 - `$PROJECT`: Replaced by `projectName` value.
 - `$COMPANY`: Replaced by `projectCompany` value.
 - `$YEAR`: Replaced by current year as four digit string.
 - `$UPDATEDATE`: Replaced by current date in the form of year, month and day with format `YYYY-MM-DD`. For example `2010-11-30`.
 
 @param string The string to replace placeholder occurences in.
 @return Returns new string with all placeholder occurences replaced.
 @see replaceAllOccurencesOfPlaceholderStringsInSettingsValues
 */
- (NSString *)stringByReplacingOccurencesOfPlaceholdersInString:(NSString *)string;

///---------------------------------------------------------------------------------------
/// @name Helper classes
///---------------------------------------------------------------------------------------

/** Returns the `GBCommentComponentsProvider` object that identifies comment components. */
@property (retain) GBCommentComponentsProvider *commentComponents;

/** Returns the `GBApplicationStringsProvider` object that specifies all string templates used for output generation. */
@property (retain) GBApplicationStringsProvider *stringTemplates;

@end
