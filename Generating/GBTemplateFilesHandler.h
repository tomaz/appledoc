//
//  GBTemplateFilesHandler.h
//  appledoc
//
//  Created by Tomaz Kragelj on 10.2.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implements common functionality for handling template files.

 Template files handler as an object that takes templates path and output path and copies all files from template path to the output path collecting all template files during the process. Template files are all files which names end with `-template` string with arbitrary extension. Such files are collected for post processing, but are not copied over to the output path. It's up to the client or sublcass to handle these files as needed. The object preserves template directory structure.

 */
@interface GBTemplateFilesHandler : NSObject

///---------------------------------------------------------------------------------------
/// @name Template files handling
///---------------------------------------------------------------------------------------

/** Copies all files from the templates path to the output path as defined in assigned `settings`, replicating the directory structure and stores all detected template files to `templateFiles` dictionary.
 
 The method uses `[GBApplicationSettingsProvider templatesPath]` as the base path for templates and `[GBApplicationSettingsProvider outputPath]` as the base path for output. In both cases, `outputSubpath` is used to determine the source and destination subdirectories. It then copies all files from template path to the output path, including the whole directory structure. If any special template file is found at source path, it is not copied! Template files are identified by having a `-template` suffix followed by optional extension. For example `object-template.html`. As this message prepares the ground for actual generation, it should be sent before any other messages (i.e. before `generateOutput:`).
 
 To further aid subclasses, the method reads out all template files in templates path and stores them to `templateFiles` dictionary. Each template file is stored with a key correspoding to it's filename, including the subdirectory within the base template path and extension.
 
 @warning *Note:* This message is intended to be sent from higher-level generator objects. Although it would present no error to run it several times, in most circumstances subclasses don't need to send it manually. If copying fails, a warning is logged and copying is stopped. Depending of type of failure, the method either returns `YES` or `NO`. If copying of all files is succesful, but reading or clearing template or ignored files fails, the operation is still considered succesful, so `YES` is returned. However if replicating the directory structure or copying files fails, this is considered an error and `NO` is returned. In such case, clients should abort further processing.
 
 
 @param error If copying fails, error description is returned here.
 @return Returns `YES` if all files were succesfully copied, `NO` otherwise.
 */
- (BOOL)copyTemplateFilesToOutputPath:(NSError **)error;

/** Returns the full path to the template ending with the given string.
 
 The method searches `templateFiles` for a key ending with the given suffix and returns full path to the given template. This is useful for getting the template for which we only know filename, but not the whole path for example.
 
 @param suffix Template file suffix to search for.
 @return Returns template path to the given template or `nil` if not found.
 @see outputPathToTemplateEndingWith:
 @see templateFiles
 */
- (NSString *)templatePathForTemplateEndingWith:(NSString *)suffix;

/** Returns the path to the template ending with the given string.
 
 The method searches `templateFiles` for a key ending with the given suffix and returns the path to the output directory corresponding to the given template subpath. This is useful for generating actual template file names - just append the desired filename and you have output file name ready!
 
 @param suffix Template file suffix to search for.
 @return Returns output path corresponding to the given template or `nil` if not found.
 @see templatePathForTemplateEndingWith:
 @see templateFiles
 */
- (NSString *)outputPathToTemplateEndingWith:(NSString *)suffix;

///---------------------------------------------------------------------------------------
/// @name Parameters handling
///---------------------------------------------------------------------------------------

/** The dictionary of all template files detected within `copyTemplateFilesToOutputPath:`.
 
 Each object has a key of template file name and relative path from `templateUserPath`. The keys are mapped to `GBTemplateHandler` instances associated with the template.
 
 This is intended to be used within subclasses only. Dictionary contents are automatically updated and should not be changed by subclasses.
 
 @see copyTemplateFilesToOutputPath:
 */
@property (strong) NSMutableDictionary *templateFiles;

/** Returns user-friendly template path string including `outputSubpath`. 
 
 This must be set prior to any handling! Send `stringByStandardizingPath` message to the returned value before using it!
 
 @see outputUserPath
 */
@property (copy) NSString *templateUserPath;

/** Returns the output path including `outputSubpath`. 
 
 This must be set prior to any handling! Send `stringByStandardizingPath` message to the returned value before using it!
 
 @see templateUserPath
 */
@property (copy) NSString *outputUserPath;

@end
