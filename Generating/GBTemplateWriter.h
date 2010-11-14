//
//  GBTemplateWriter.h
//  appledoc
//
//  Created by Tomaz Kragelj on 30.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGTemplateEngine.h"

@class GBTemplateReader;

/** Generates output using template data from a given `GBTemplateReader` and variables.
 
 This is used for generating output strings from templates. Basically the class is a simple wrapper over `MGTemplateEngine`, `GBTemplateReader` and matching variables dictionary. Although this could easily be implemented within `GBTemplateReader`, creating a separate class results in cleaner encapsulation of logic and simpler template engine delegate methods dealing with a single task only.
 
 The class is designed to be reusable - there's no need to create a new instance for each object or even template type. Simply create an instance and then send it `outputStringWithReader:variables:` message. Each time the message is sent, a clean writing session is started.
 */
@interface GBTemplateWriter : NSObject <MGTemplateEngineDelegate> {
	@private
	MGTemplateEngine *_engine;
}

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------

/** Returns autoreleased writer that work with the given `GBApplicationSettingsProvider` implementor.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
+ (id)writerWithSettingsProvider:(id)settingsProvider;

/** Initializes the writer to work with the given `GBApplicationSettingsProvider` implementor.
 
 This is the designated initializer.
 
 @param settingsProvider Application-wide settings provider to use for checking parameters.
 @return Returns initialized instance or `nil` if initialization fails.
 @exception NSException Thrown if the given application is `nil`.
 */
- (id)initWithSettingsProvider:(id)settingsProvider;

///---------------------------------------------------------------------------------------
/// @name Output generation
///---------------------------------------------------------------------------------------

/** Generates the output string using the given `GBTemplateReader` and matching variables set.
 
 This method is the driving force behind output generation, although it's quite simple behind the scenes. It can product output for any given template as the template itself is defined by the given `GBTemplateReader` instance. The client is also responsible to provide proper set of variables that match expectations from the reader's template string. Internally, the writer simply passes the given reader's template string together with the given set of variables to it's own `MGTemplateEngine` instance and then runs it. If a template section placeholder is found within the template, another `MGTemplateEngine` instance is used for generating concrete string which is then inserted to the original string in place of the template placeholder.
 
 Note that there's no need to specify the actual template string; it's taken from the given reader automatically. The given set of variables can only contain variables required by the reader's template, common strings are automatically added from the assigned `GBApplicationSettingsProvider`.
 
 @param reader `GBTemplateReader` that defines template with the template string.
 @param variables Dictionary containing all variables required by the template.
 @return Returns generated output.
 @exception NSException Thrown if the given `reader` is `nil`.
 */
- (NSString *)outputStringWithReader:(GBTemplateReader *)reader variables:(NSDictionary *)variables;

@end
