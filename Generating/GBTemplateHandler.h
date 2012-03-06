//
//  GBTemplateHandler.h
//  appledoc
//
//  Created by Tomaz Kragelj on 17.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GRMustacheTemplate;

/** Loads a template file, prepares it for output generation and renders the output on any given object.
 
 The main responsibilities of this class are loading template from file to string, parsing and extractng all template sections and rendering the template for any given object. As the first two tasks are actually combined into a single method, public API is even simpler: just create one instance of the class for each different template by sending `parseTemplateFromPath:error:` or `parseTemplate:error:` which loads, parses and verifies the template. Then send `renderObject:` to generate output from a concrete object. 
 
 Note that, as said above, there is no need to create a new `GBTemplateHandler` instance for each object for which we want to render output. It's enough and much more efficient to create a single instance for each different type of template and use it to generate as many objects from that template as needed.
 */
@interface GBTemplateHandler : NSObject {
	@private
	NSString *_templateString;
	NSMutableDictionary *_templateSections;
	GRMustacheTemplate *_template;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns a new autoreleased `GBTemplateHandler`. */
+ (id)handler;

- (NSString*)templateString;

///---------------------------------------------------------------------------------------
/// @name Parsing
///---------------------------------------------------------------------------------------

/** Parses template file from the given path and converts it into a ready-to-use template.
 
 The results are parsed into `templateString` and `templateSections`. After reading the template from the file, you can re-use the class for generating all objects that need to be templated from read template. That is, there's no need of re-parsing the same template for each generation.
 
 @param path The name of the template file to parse.
 @param error If reading or parsing fails, error message is returned here.
 @return Returns `YES` if parsing was sucesful, `NO` otherwise.
 @see parseTemplate:error:
 @see renderObject:
 */
- (BOOL)parseTemplateFromPath:(NSString *)path error:(NSError **)error;

/** Parses the given template string and converts it into a ready-to-use template.
 
 The results are parsed into `templateString` and `templateSections`. After reading the template from the file, you can re-use the class for generating all objects that need to be templated from read template. That is, there's no need of re-parsing the same template for each generation.
 
 @param string The template string to parse.
 @param error If parsing fails, error message is returned here.
 @return Returns `YES` if parsing was sucesful, `NO` otherwise.
 @see parseTemplateFromPath:error:
 @see renderObject:
 */
- (BOOL)parseTemplate:(NSString *)string error:(NSError **)error;

///---------------------------------------------------------------------------------------
/// @name Rendering
///---------------------------------------------------------------------------------------

/** Renders the given object using current template data.
 
 This is where template placeholders get replaced with actual values from the given object and as thus the main focus of the `GBTemplateHandler` class. The object must contain all expected variables as defined by the template. Failing to provide required values will result in that part of the template being ignored, but may also result in unpredicted behavior, so it's better to make sure proper objects are passed to proper templates.
 
 @warning *Important:* Note that this message can only be sent after parsing template with one of the parsing methods! Sending the message to a class with no parsed data results in a warning and empty string being returned.
 
 @param object The object containins data to be replaced by template placeholders.
 @return Returns generated output string.
 @see parseTemplateFromPath:error:
 @see parseTemplate:error:
 */
- (NSString *)renderObject:(id)object;

@end
