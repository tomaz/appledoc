//
//  GBTemplateLoader.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Loads a template file and prepares it for output generation.
 
 The main responsibilities of this class are loading template from file to string, scanning for all template subsections and extracting them to internal dictionary. Finally, it prepares clean template file, without all template subsections. Note that processed template can be reused - it's enough to process a single template file once and then reuse the `GBTemplateLoader` instance for all cases where the given template is needed.
 */
@interface GBTemplateLoader : NSObject {
	@private
	NSString *_templateString;
	NSMutableDictionary *_templateSections;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBTemplateLoader`. */
+ (id)loader;

///---------------------------------------------------------------------------------------
/// @name Parsing
///---------------------------------------------------------------------------------------

/** Parses template file from the given path and converts it into a ready-to-use template.
 
 The results are parsed into `templateString` and `templateSections`. After reading the template from the file, you can re-use the class for generating all objects that need to be templated from read template. That is, there's no need of re-parsing the same template for each generation.
 
 @param path The name of the template file to parse.
 @param error If reading or parsing fails, error message is returned here.
 @return Returns `YES` if parsing was sucesful, `NO` otherwise.
 @see parseTemplate:error:
 @see templateString
 @see templateSections
 */
- (BOOL)parseTemplateFromPath:(NSString *)path error:(NSError **)error;

/** Parses the given template string and converts it into a ready-to-use template.
 
 The results are parsed into `templateString` and `templateSections`. After reading the template from the file, you can re-use the class for generating all objects that need to be templated from read template. That is, there's no need of re-parsing the same template for each generation.
 
 @param path The template string to parse.
 @param error If parsing fails, error message is returned here.
 @return Returns `YES` if parsing was sucesful, `NO` otherwise.
 @see parseTemplateFromPath:error:
 @see templateString
 @see templateSections
 */
- (BOOL)parseTemplate:(NSString *)template error:(NSError **)error;

/** Template string without all sections as parsed the last time `parseTemplateFromPath:error:` was sent.
 
 @see parseTemplateFromPath:error:
 @see parseTemplate:error:
 @see templateSections
 */
@property (readonly) NSString *templateString;

/** Template sections from the template as parsed the last time `parseTemplateFromPath:error:` was sent.
 
 @see parseTemplateFromPath:error:
 @see parseTemplate:error:
 @see templateString
 */
@property (readonly) NSDictionary *templateSections;

@end
