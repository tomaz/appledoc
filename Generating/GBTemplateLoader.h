//
//  GBTemplateLoader.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Loads a template file, prepares it for output generation and renders the output on any given object.
 
 The main responsibilities of this class are loading template from file to string, parsing and extractng all template sections and rendering the template for any given object. As the first two tasks are actually combined into a single method, public API is even simpler: just create one instance of the class for each different template by sending `parseTemplateFromPath:error:` or `parseTemplate:error:` which loads, parses and verifies the template. Then send `renderObject:` to generate output from a concrete object. 
 
 Note that, as said above, there is no need to create a new `GBTemplateLoader` instance for each object for which we want to render output. It's enough and much more efficient to create a single instance for each different type of template and use it to generate as many objects from that template as needed.
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
 */
- (BOOL)parseTemplateFromPath:(NSString *)path error:(NSError **)error;

/** Parses the given template string and converts it into a ready-to-use template.
 
 The results are parsed into `templateString` and `templateSections`. After reading the template from the file, you can re-use the class for generating all objects that need to be templated from read template. That is, there's no need of re-parsing the same template for each generation.
 
 @param path The template string to parse.
 @param error If parsing fails, error message is returned here.
 @return Returns `YES` if parsing was sucesful, `NO` otherwise.
 @see parseTemplateFromPath:error:
 */
- (BOOL)parseTemplate:(NSString *)template error:(NSError **)error;

@end
