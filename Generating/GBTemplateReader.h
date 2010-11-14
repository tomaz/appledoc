//
//  GBTemplatesReader.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTemplateEngine.h"

/** Reads all template sections from the given template file and provides them to the rest of the application.
 */
@interface GBTemplateReader : NSObject <MGTemplateEngineDelegate> {
	@private
	MGTemplateEngine *_engine;
	NSString *_templateString;
	NSMutableDictionary *_templates;
	NSMutableDictionary *_templateLocations;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased reader that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)readerWithSettingsProvider:(id)settingsProvider;

/** Initializes the reader to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Template reading handling
///---------------------------------------------------------------------------------------

/** Reads all template sections from the given template string and stores them to properties.
 
 The method scans the given template string for declared template sections and stores them to properties so the clients can access them late on. The results are available through `templates` property. If the given string is empty, or no template sections are found in the given string, current templates are cleared only. If any incosistency is detected, a warning is issued to the log, but processing continues.
 
 @param string Template string to scan.
 @exception NSException Thrown if the given string is `nil`.
 @see valueOfTemplateWithName:
 @see templates
 */
- (void)readTemplateSectionsFromTemplate:(NSString *)string;

///---------------------------------------------------------------------------------------
/// @name Data handling
///---------------------------------------------------------------------------------------

/** Returns the string value of the template with the given name or `nil` if the name is not recognized.

 Although you could get the template string through `templates` dictionary, you would need to extract the value from the object returned. To avoid incosistency, it is recommended to use this method instead.
 
 @param name The name of the template to read.
 @return Returns template value or `nil` if name is not recognized.
 @see argumentsOfTemplateWithName:
 */
- (NSString *)valueOfTemplateWithName:(NSString *)name;

/** Returns an array of expected arguments of the template with the given name or `nil` if the name is not recognized.
 
 Although you could get the template arguments through `templates` dictionary, you would need to extract the value from the object returned. To avoid incosistency, it is recommended to use this method instead.
 
 @param name The name of the template to read.
 @return Returns expected template arguments or `nil` if name is not recognized.
 @see valueOfTemplateWithName:
 */
- (NSArray *)argumentsOfTemplateWithName:(NSString *)name;

/** All templates read from the last time `readTemplateSectionsFromTemplate` was sent.
 
 The dictionary uses template names as keys and dictionaries with template values and expected arguments as values.
 
 @see valueOfTemplateWithName:
 @see readTemplateSectionsFromTemplate:
 */
@property (readonly) NSDictionary *templates;

/** The template string from which `templates` were read.
 
 This value is automatically assigned within `readTemplateSectionsFromTemplate:`.
 */
@property (readonly) NSString *templateString;

@end
