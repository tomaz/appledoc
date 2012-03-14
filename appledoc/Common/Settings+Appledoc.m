//
//  Settings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "CommandLineArgumentsParser.h"
#import "Settings+Appledoc.h"

@implementation Settings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(Settings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:GBSettingsKeys.inputPaths];
	}
	return result;
}

#pragma mark - Project information

GB_SYNTHESIZE_COPY(NSString *, projectVersion, setProjectVersion)
GB_SYNTHESIZE_COPY(NSString *, projectName, setProjectName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyName, setCompanyName) // Required!
GB_SYNTHESIZE_COPY(NSString *, companyIdentifier, setCompanyIdentifier) // Required!

#pragma mark - Paths

GB_SYNTHESIZE_OBJECT(NSArray *, inputPaths, setInputPaths)

#pragma mark - Debugging aid

GB_SYNTHESIZE_BOOL(printSettings, setPrintSettings)

@end

#pragma mark -

@implementation Settings (Helpers)

- (void)applyFactoryDefaults {
	self.projectVersion = @"1.0";
}

- (void)applyGlobalSettingsFromCmdLineSettings:(Settings *)settings {
}

- (void)applyProjectSettingsFromCmdLineSettings:(Settings *)settings {
}

- (void)registerOptionsToCommandLineParser:(CommandLineArgumentsParser *)parser {
	[parser registerOption:GBSettingsKeys.projectName shortcut:'p' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.projectVersion shortcut:'v' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyName shortcut:'c' requirement:GBCommandLineValueRequired];
	[parser registerOption:GBSettingsKeys.companyIdentifier requirement:GBCommandLineValueRequired];
	
	[parser registerSwitch:GBSettingsKeys.printSettings];
	
	[parser registerSwitch:@"version"];
	[parser registerSwitch:@"help" shortcut:'?'];
}

@end

#pragma mark -

@implementation Settings (Diagnostics)

- (void)printSettingValuesIfNeeded {
	if (!self.printSettings) return;
	
	#define GB_ADD_SETTING(key) { \
		NSMutableArray *columns = [NSMutableArray array]; \
		Settings *settings = self; \
		while (settings) { \
			if (columns.count == 0) { \
				lengths[0] = MAX(key.length, lengths[0]); \
				[columns addObject:key]; \
			} \
			if (rows.count == 1) { \
				lengths[columns.count] = settings.name.length; \
				[headers addObject:settings.name]; \
			} \
			NSString *value = [settings isKeyPresentAtThisLevel:key] ? [settings objectForKey:key] : @""; \
			lengths[columns.count] = MAX(value.length, lengths[columns.count]); \
			[columns addObject:value]; \
			settings = settings.parent; \
		} \
		[rows addObject:columns]; \
	}
	
	ddprintf(@"Input files and paths:\n");
	for (NSString *path in self.inputPaths) ddprintf(@"- %@\n", path);
	ddprintf(@"\n");
	
	// Prepare the data.
	NSUInteger lengths[] = { 0, 0, 0, 0, 0, 0 }; // Just use plain C array to simplify calculations with risk of overflowing if adding more levels...
	NSMutableArray *rows = [NSMutableArray array];
	NSMutableArray *headers = [NSMutableArray arrayWithObject:@"Setting"];
	[rows addObject:headers];
	GB_ADD_SETTING(GBSettingsKeys.projectName)
	GB_ADD_SETTING(GBSettingsKeys.projectVersion)
	GB_ADD_SETTING(GBSettingsKeys.companyName)
	GB_ADD_SETTING(GBSettingsKeys.companyIdentifier)

	// Draw all rows. Note that we need to use pointer to C array otherwise clang complains...
	NSUInteger *columnLengths = lengths;	
	[rows enumerateObjectsUsingBlock:^(NSArray *columns, NSUInteger rowIdx, BOOL *stopRow) {
		[columns enumerateObjectsUsingBlock:^(NSString *value, NSUInteger colIdx, BOOL *stopCol) {
			NSUInteger columnSize = columnLengths[colIdx];
			NSUInteger valueSize = value.length;
			ddprintf(@"%@", value);
			while (valueSize <= columnSize) {
				ddprintf(@" ");
				valueSize++;
			}
		}];
		if (rowIdx == 0) ddprintf(@"\n");
		ddprintf(@"\n");
	}];
}

+ (void)printAppledocVersion {
	ddprintf(@"appledoc: version 3.0a1 (build 100)\n");
	ddprintf(@"\n");
}

+ (void)printAppledocHelp {
	ddprintf(@"Usage: appledoc [OPTIONS] <paths to files or dirs>\n");
}

@end

#pragma mark -

const struct GBSettingsKeys GBSettingsKeys = {
	.projectName = @"project-name",
	.projectVersion = @"project-version",
	.companyName = @"company-name",
	.companyIdentifier = @"company-id",
	
	.inputPaths = @"input",
	
	.printSettings = @"print-settings",
};