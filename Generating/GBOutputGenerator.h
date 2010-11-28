//
//  GBOutputGenerator.h
//  appledoc
//
//  Created by Tomaz Kragelj on 28.11.10.
//  Copyright 2010 Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The base class for all output generators.
 
 Output generator is an object that handles a specific spet while generating output. These are helper classes for `GBGenerator` class; each concrete subclass handles specifics for certain step. Generator just ties all of these together into properly ordered chain as required by command line parameters.
 */
@interface GBOutputGenerator : NSObject

///---------------------------------------------------------------------------------------
/// @name Templates handling
///---------------------------------------------------------------------------------------

/** Copies all files from the given templates path to the given output path, replicating the directory structure.
 
 The method uses `outputPath` to determine the source and destination subdirectories relative to the given paths. It then copies all files from template path to the output path, including the whole directory structure. If any special template file is found at source path, it is not copied! Template files are identified by having a `-template` suffix followed by optional extension. For example `object-template.html`. As this message prepares the ground for actual generation, it should be sent before any other messages.
 
 If copying fails, the error is logged to console and `NO` is returned.
 
 @param sourcePath The source path to copy from.
 @param destPath The destination path to copy to.
 @return Returns `YES` if all files were succesfully copied, `NO` otherwise.
 */
- (BOOL)copyTemplateFilesFromPath:(NSString *)sourcePath toPath:(NSString *)destPath;

/** Returns the path relative to main output path, where all generated data is stored.
 
 At the same this, this also defines the path relative to main templates path, where all template files for this output generator are stored. Default implementation simply returns empty string, each subclass is supposed to override and return prover value.
 
 @see copyTemplateFilesFromPath:toPath:
  */
@property (readonly) NSString *outputSubpath;

@end
