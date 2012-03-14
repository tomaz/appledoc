//
//  Settings+Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//
#import "DDCliUtil.h"
#import "AppledocInfo.h"
#import "CommandLineArgumentsParser.h"
#import "Settings+Definitions.h"
#import "Settings+Appledoc.h"

@implementation Settings (Appledoc)

#pragma mark - Initialization & disposal

+ (id)appledocSettingsWithName:(NSString *)name parent:(Settings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
		[result registerArrayForKey:@"input"];
	}
	return result;
}

#pragma mark - Project information

GB_SYNTHESIZE_COPY(NSString *, projectVersion, setProjectVersion, @"project-version")
GB_SYNTHESIZE_COPY(NSString *, projectName, setProjectName, @"project-name") // Required!
GB_SYNTHESIZE_COPY(NSString *, companyName, setCompanyName, @"company-name") // Required!
GB_SYNTHESIZE_COPY(NSString *, companyIdentifier, setCompanyIdentifier, @"company-id") // Required!

#pragma mark - Paths

GB_SYNTHESIZE_OBJECT(NSArray *, inputPaths, setInputPaths, @"input")

#pragma mark - Debugging aid

GB_SYNTHESIZE_BOOL(printSettings, setPrintSettings, @"print-settings")

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
	// Enumerate all options and ignore separators. Note that we don't have to register internal options as these aren't parsed on command line!
	GBEnumerateOptions(^(GBOptionDefinition *option, BOOL *stop) {
		if (!GBOptionIsCmdLine(option)) return;
		NSUInteger requirement = GBOptionRequirements(option);
		[parser registerOption:option->longOption shortcut:option->shortOption requirement:requirement];
	});
}

@end

#pragma mark -

@implementation Settings (Diagnostics)

- (void)printSettingValuesIfNeeded {
	if (!self.printSettings) return;
	
#define GB_UPDATE_MAX_LENGTH(value) \
	NSNumber *length = [lengths objectAtIndex:columns.count]; \
	NSUInteger maxLength = MAX(value.length, length.unsignedIntegerValue); \
	if (maxLength > length.unsignedIntegerValue) { \
		NSNumber *newMaxLength = [NSNumber numberWithUnsignedInteger:maxLength]; \
		[lengths replaceObjectAtIndex:columns.count withObject:newMaxLength]; \
	}

	ddprintf(@"Input files and paths:\n");
	for (NSString *path in self.inputPaths) ddprintf(@"- %@\n", path);
	ddprintf(@"\n");
	
	NSMutableArray *rows = [NSMutableArray array];
	NSMutableArray *lengths = [NSMutableArray array];
	
	// First add header row. Note that first element is the setting.
	NSMutableArray *headers = [NSMutableArray arrayWithObject:@"Setting"];
	[lengths addObject:[NSNumber numberWithUnsignedInteger:[headers.lastObject length]]];
	[self enumerateSettings:^(Settings *settings, BOOL *stop) {
		[headers addObject:settings.name];
		[lengths addObject:[NSNumber numberWithUnsignedInteger:settings.name.length]];
	}];
	[rows addObject:headers];
	
	// Append all rows for options.
	GBEnumerateOptions(^(GBOptionDefinition *option, BOOL *stop) {
		if (!GBOptionIsPrint(option)) return;
		
		// Add separator. Note that we don't care about its length, we'll simply draw it over the whole line if needed.
		if (GBOptionIsSeparator(option)) {
			NSArray *separators = [NSArray arrayWithObject:option->description];
			[rows addObject:[NSArray array]];
			[rows addObject:separators];
			return;
		}
		
		// Prepare values array. Note that the first element is simply the name of the option.
		NSMutableArray *columns = [NSMutableArray array];
		NSString *longOption = option->longOption;
		GB_UPDATE_MAX_LENGTH(longOption)
		[columns addObject:longOption];

		// Now append value for the option on each settings level and update maximum size.
		[self enumerateSettings:^(Settings *settings, BOOL *stop) {
			NSString *value = [settings isKeyPresentAtThisLevel:longOption] ? [[settings objectForKey:longOption] description] : @"";
			GB_UPDATE_MAX_LENGTH(value)
			[columns addObject:value];
		}];
		
		// Add the row.
		[rows addObject:columns];
	});

	// Draw all rows.
	[rows enumerateObjectsUsingBlock:^(NSArray *columns, NSUInteger rowIdx, BOOL *stopRow) {
		[columns enumerateObjectsUsingBlock:^(NSString *value, NSUInteger colIdx, BOOL *stopCol) {
			NSUInteger columnSize = [[lengths objectAtIndex:colIdx] unsignedIntegerValue];
			NSUInteger valueSize = value.length;
			ddprintf(@"%@", value);
			while (valueSize <= columnSize) {
				ddprintf(@" ");
				valueSize++;
			}
		}];
		ddprintf(@"\n");
	}];
}

+ (void)printAppledocVersion {
	ddprintf(@"%@: version %@ (build %lu)\n", GB_APPLEDOC_NAME, GB_APPLEDOC_VERSION, GB_APPLEDOC_BUILD);
	ddprintf(@"\n");
}

+ (void)printAppledocHelp {
	ddprintf(@"Usage: %@ [OPTIONS] <paths to files or dirs>\n", GB_APPLEDOC_NAME);
	ddprintf(@"\n");
}

@end
