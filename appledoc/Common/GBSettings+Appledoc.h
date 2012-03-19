//
//  GBSettings+Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings.h"

@class GBCommandLineParser;

/** All appledoc settings as simple properties.
 
 This category extends Settings class by providing simple interface so we don't have to deal with keys. To use it, simply import the header and use the properties. If the instance represents factory defaults, send it applyFactoryDefaults message - it nicely embeds default settings within the category implementation.
 
 @warning **Implementation detail:** Note that we could easily add all properties directly to Settings, but as the class is designed to be as reusable as possible, that would break reusability. All in all, Objective C offers powerful extending mechanism in the form of categories, and this seems like a perfect fit.
 */
@interface GBSettings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(GBSettings *)parent;

#pragma mark - Project information

@property (nonatomic, copy) NSString *projectVersion;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *companyIdentifier;

#pragma mark - Paths

@property (nonatomic, strong) NSArray *inputPaths;
@property (nonatomic, strong) NSString *templatesPath;

#pragma mark - Debugging aid

@property (nonatomic, assign) NSUInteger loggingFormat;
@property (nonatomic, assign) NSUInteger loggingLevel;
@property (nonatomic, assign) BOOL printSettings;
@property (nonatomic, assign) BOOL printVersion;
@property (nonatomic, assign) BOOL printHelp;

@end

#pragma mark - 

extern const struct GBOptions {
	__unsafe_unretained NSString *projectVersion;
	__unsafe_unretained NSString *projectName;
	__unsafe_unretained NSString *companyName;
	__unsafe_unretained NSString *companyIdentifier;
	
	__unsafe_unretained NSString *inputPaths;
	__unsafe_unretained NSString *templatesPath;
	
	__unsafe_unretained NSString *loggingFormat;
	__unsafe_unretained NSString *loggingLevel;
	__unsafe_unretained NSString *printSettings;
	__unsafe_unretained NSString *printVersion;
	__unsafe_unretained NSString *printHelp;
} GBOptions;
