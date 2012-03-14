//
//  Settings+Appledoc.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Settings.h"

@class CommandLineArgumentsParser;

/** All appledoc settings as simple properties.
 
 This category extends Settings class by providing simple interface so we don't have to deal with keys. To use it, simply import the header and use the properties. If the instance represents factory defaults, send it applyFactoryDefaults message - it nicely embeds default settings within the category implementation.
 
 @warning **Implementation detail:** Note that we could easily add all properties directly to Settings, but as the class is designed to be as reusable as possible, that would break reusability. All in all, Objective C offers powerful extending mechanism in the form of categories, and this seems like a perfect fit.
 */
@interface Settings (Appledoc)

#pragma mark - Project values

@property (nonatomic, copy) NSString *projectVersion;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *companyIdentifier;

#pragma mark - Helper methods

- (void)applyFactoryDefaults;
- (void)registerOptionsToCommandLineParser:(CommandLineArgumentsParser *)parser;

@end

#pragma mark - Settings keys

/** All the keys used for settings defined in a convenient namespaced struct.
 
 Note that these are purposely made equal to command line arguments for simpler handling!
 */
extern const struct GBSettingsKeys {
	__unsafe_unretained NSString *projectName;
	__unsafe_unretained NSString *projectVersion;
	__unsafe_unretained NSString *companyName;
	__unsafe_unretained NSString *companyIdentifier;
} GBSettingsKeys;