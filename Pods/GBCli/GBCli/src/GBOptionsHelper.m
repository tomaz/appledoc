//
//  GBOptionsHelper.m
//  GBCli
//
//  Created by Tomaž Kragelj on 3/15/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBSettings.h"
#import "GBOptionsHelper.h"

static NSUInteger GBOptionInternalEndGroup = 1 << 10;

#pragma mark -

@interface OptionDefinition : NSObject
@property (nonatomic, assign) char shortOption;
@property (nonatomic, copy) NSString *longOption;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) GBOptionFlags flags;
@end

@implementation OptionDefinition
@synthesize description = _description;
@end

#pragma mark - 

@interface GBOptionsHelper ()
@property (nonatomic, strong) NSMutableArray *registeredOptions;
@end

#pragma mark -

@implementation GBOptionsHelper

#pragma mark - Initialization & disposal

- (instancetype)init {
	self = [super init];
	if (self) {
		self.registeredOptions = [NSMutableArray array];
	}
	return self;
}

#pragma mark - Options registration

- (void)registerOptionsFromDefinitions:(GBOptionDefinition *)definitions {
	GBOptionDefinition *definition = definitions;
	while (definition->longOption || definition->description) {
		[self registerOption:definition->shortOption long:definition->longOption description:definition->description flags:definition->flags];
		definition++;
	}
}

- (void)registerSeparator:(NSString *)description {
	[self registerOption:0 long:nil description:description flags:GBOptionSeparator];
}

- (void)registerGroup:(NSString *)name description:(NSString *)description optionsBlock:(void(^)(GBOptionsHelper *options))block {
	[self registerGroup:name description:description flags:0 optionsBlock:block];
}

- (void)registerGroup:(NSString *)name description:(NSString *)description flags:(GBOptionFlags)flags optionsBlock:(void(^)(GBOptionsHelper *options))block {
	NSParameterAssert(block != nil);
	OptionDefinition *definition = [[OptionDefinition alloc] init];
	definition.shortOption = 0;
	definition.longOption = name;
	definition.description = description;
	definition.flags = GBOptionGroup | flags;
	[self.registeredOptions addObject:definition];
	
	block(self);
	
	OptionDefinition *endDefinition = [[OptionDefinition alloc] init];
	endDefinition.flags = GBOptionInternalEndGroup;
	[self.registeredOptions addObject:endDefinition];
}

- (void)registerOption:(char)shortName long:(NSString *)longName description:(NSString *)description flags:(GBOptionFlags)flags {
	OptionDefinition *definition = [[OptionDefinition alloc] init];
	definition.shortOption = shortName;
	definition.longOption = longName;
	definition.description = description;
	definition.flags = flags;
	[self.registeredOptions addObject:definition];
}

#pragma mark - Integration with other components

- (void)registerOptionsToCommandLineParser:(GBCommandLineParser *)parser {
	[self enumerateOptions:^(OptionDefinition *definition, BOOL *stop) {
		if (![self isCmdLine:definition]) return;
		if ([self isSeparator:definition]) return;
		
		if ([self isOptionGroup:definition]) {
			[parser beginRegisterOptionGroup:definition.longOption];
			return;
		}
		
		if ([self isOptionGroupEnd:definition]) {
			[parser endRegisterOptionGroup];
			return;
		}
		
		NSUInteger requirements = [self requirements:definition];
		[parser registerOption:definition.longOption shortcut:definition.shortOption requirement:requirements];
	}];
}

#pragma mark - Diagnostic info

- (void)printValuesFromSettings:(GBSettings *)settings {	
#define GB_UPDATE_MAX_LENGTH(value) \
	NSNumber *length = [lengths objectAtIndex:columns.count]; \
	NSUInteger maxLength = MAX(value.length, length.unsignedIntegerValue); \
	if (maxLength > length.unsignedIntegerValue) { \
	NSNumber *newMaxLength = @(maxLength); \
	[lengths replaceObjectAtIndex:columns.count withObject:newMaxLength]; \
}
	NSMutableArray *rows = [NSMutableArray array];
	NSMutableArray *lengths = [NSMutableArray array];
	__weak GBOptionsHelper *blockSelf = self;
	__block NSUInteger settingsHierarchyLevels = 0;
	
	// First add header row. Note that first element is the setting.
	NSMutableArray *headers = [NSMutableArray arrayWithObject:@"Option"];
	[lengths addObject:@([headers.lastObject length])];
	[settings enumerateSettings:^(GBSettings *settings, BOOL *stop) {
		[headers addObject:settings.name];
		[lengths addObject:@(settings.name.length)];
		settingsHierarchyLevels++;
	}];
	[rows addObject:headers];
	
	// Append all rows for options.
	__block NSUInteger lastSeparatorIndex = 0;
	[self enumerateOptions:^(OptionDefinition *definition, BOOL *stop) {
		if (![blockSelf isPrint:definition]) return;
		if ([self isOptionGroupEnd:definition]) return;
		
		// Add separator. Note that we don't care about its length, we'll simply draw it over the whole line if needed.
		if ([blockSelf isSeparator:definition]) {
			if (rows.count == lastSeparatorIndex) {
				[rows removeLastObject];
				[rows removeLastObject];
			}
			[rows addObject:@[]];
			[rows addObject:@[ definition.description ] ];
			lastSeparatorIndex = rows.count;
			return;
		}
		
		// Add group.
		if ([blockSelf isOptionGroup:definition]) {
			NSMutableString *description = [definition.longOption mutableCopy];
			if ([definition.description length] > 0) [description appendFormat:@" %@", definition.description];
			[rows addObject:@[]];
			[rows addObject:@[ description ]];
			return;
		}
		
		NSMutableArray *columns = [NSMutableArray array];
		NSString *longOption = definition.longOption;
		GB_UPDATE_MAX_LENGTH(longOption)
		[columns addObject:longOption];
		
		// Now append value for the option on each settings level and update maximum size.
		[settings enumerateSettings:^(GBSettings *settings, BOOL *stop) {
			NSString *columnData = @"";
			if ([settings isKeyPresentAtThisLevel:longOption]) {
				id value = [settings objectForKey:longOption];
				if ([settings isKeyArray:longOption]) {
					NSMutableString *arrayValue = [NSMutableString string];
					[(NSArray *)value enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
						GBSettings *level = [settings settingsForArrayValue:obj key:longOption];
						if (level != settings) return;
						if (arrayValue.length > 0) [arrayValue appendString:@", "];
						[arrayValue appendString:obj];
					}];
					columnData = arrayValue;
				} else {
					columnData = [value description];
				}
			}
			GB_UPDATE_MAX_LENGTH(columnData)
			[columns addObject:columnData];
		}];
		
		// Add the row.
		[rows addObject:columns];
	}];
	
	// Remove last separator if there were no values.
	if (rows.count == lastSeparatorIndex) {
		[rows removeLastObject];
		[rows removeLastObject];
	}

	// Render header.
	[self replacePlaceholdersAndPrintStringFromBlock:self.printValuesHeader];
	
	// Render all arguments if any.
	if (settings.arguments.count > 0) {
		[self replacePlaceholdersAndPrintStringFromBlock:self.printValuesArgumentsHeader];
		[settings.arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger idx, BOOL *stop) {
			printf("- %s", argument.UTF8String);
			if (settingsHierarchyLevels > 1) {
				GBSettings *level = [settings settingsForArgument:argument];
				printf(" (%s)", level.name.UTF8String);
			}
			printf("\n");
		}];
		printf("\n");
	}
	
	// Render all rows.
	[self replacePlaceholdersAndPrintStringFromBlock:self.printValuesOptionsHeader];
	[rows enumerateObjectsUsingBlock:^(NSArray *columns, NSUInteger rowIdx, BOOL *stopRow) {
		NSMutableString *output = [NSMutableString string];
		[columns enumerateObjectsUsingBlock:^(NSString *value, NSUInteger colIdx, BOOL *stopCol) {
			NSUInteger columnSize = [[lengths objectAtIndex:colIdx] unsignedIntegerValue];
			NSUInteger valueSize = value.length;
			[output appendString:value];
			while (valueSize <= columnSize) {
				[output appendString:@" "];
				valueSize++;
			}
		}];
		printf("%s\n", output.UTF8String);
	}];
	
	// Render footer.
	[self replacePlaceholdersAndPrintStringFromBlock:self.printValuesFooter];
}

- (void)printVersion {
	NSMutableString *output = [NSMutableString stringWithFormat:@"%@", self.applicationNameFromBlockOrDefault];
	NSString *version = self.applicationVersionFromBlockOrNil;
	NSString *build = self.applicationBuildFromBlockOrNil;
	if (version) [output appendFormat:@": version %@", version];
	if (build) [output appendFormat:@" (build %@)", build];
	printf("%s\n", output.UTF8String);
}

- (void)printHelp {	
	// Prepare all rows.
	__block NSUInteger maxNameTypeLength = 0;
	__block NSUInteger lastSeparatorIndex = NSNotFound;
	NSMutableArray *rows = [NSMutableArray array];
	[self enumerateOptions:^(OptionDefinition *definition, BOOL *stop) {
		if (![self isHelp:definition]) return;
		if ([self isOptionGroupEnd:definition]) return;
		
		// Prepare separator. Remove previous one if there were no values prepared for it.
		if ([self isSeparator:definition]) {
			if (rows.count == lastSeparatorIndex) {
				[rows removeLastObject];
				[rows removeLastObject];
			}
			[rows addObject:@[]];
			[rows addObject:@[ definition.description ]];
			lastSeparatorIndex = rows.count;
			return;
		}
		
		// Add group.
		if ([self isOptionGroup:definition]) {
			NSMutableString *description = [definition.longOption mutableCopy];
			if ([definition.description length] > 0) [description appendFormat:@" %@", definition.description];
			[rows addObject:@[]];
			[rows addObject:@[ description ]];
			return;
		}
		
		// Prepare option description.
		NSString *shortOption = (definition.shortOption > 0) ? [NSString stringWithFormat:@"-%c", definition.shortOption] : @"  ";
		NSString *longOption = [NSString stringWithFormat:@"--%@", definition.longOption];
		NSString *description = definition.description ? definition.description : @"";
		NSUInteger requirements = [self requirements:definition];
		
		// Prepare option type and update longest option+type string size for better alignment later on.
		NSString *type = @"";
		if (requirements == GBValueRequired)
			type = @" <value>";
		else if (requirements == GBValueOptional)
			type = @" [<value>]";
		maxNameTypeLength = MAX(longOption.length + type.length, maxNameTypeLength);
		NSString *nameAndType = [NSString stringWithFormat:@"%@%@", longOption, type];
		
		// Add option info to rows array.
		NSMutableArray *columns = [NSMutableArray array];
		[columns addObject:shortOption];
		[columns addObject:nameAndType];
		[columns addObject:description];
		[rows addObject:columns];
	}];
	
	// Remove last separator if there were no values.
	if (rows.count == lastSeparatorIndex) {
		[rows removeLastObject];
		[rows removeLastObject];
	}
	
	// Render header.
	[self replacePlaceholdersAndPrintStringFromBlock:self.printHelpHeader];
	
	// Render all rows aligning long option columns properly.
	[rows enumerateObjectsUsingBlock:^(NSArray *columns, NSUInteger rowIdx, BOOL *stop) {
		NSMutableString *output = [NSMutableString string];
		[columns enumerateObjectsUsingBlock:^(NSString *column, NSUInteger colIdx, BOOL *stop) {
			[output appendFormat:@"%@ ", column];
			if (colIdx == 1) {
				NSUInteger length = column.length;
				while (length < maxNameTypeLength) {
					[output appendString:@" "];
					length++;
				}
			}
		}];
		printf("%s\n", output.UTF8String);
	}];
	
	// Render footer.
	[self replacePlaceholdersAndPrintStringFromBlock:self.printHelpFooter];
}

#pragma mark - Application information

- (NSString *)applicationNameFromBlockOrDefault {
	if (self.applicationName) return self.applicationName();
	NSProcessInfo *process = [NSProcessInfo processInfo];
	return process.processName;
}

- (NSString *)applicationVersionFromBlockOrNil {
	if (self.applicationVersion) return self.applicationVersion();
	return nil;
}

- (NSString *)applicationBuildFromBlockOrNil {
	if (self.applicationBuild) return self.applicationBuild();
	return nil;
}

#pragma mark - Rendering helpers

- (void)replacePlaceholdersAndPrintStringFromBlock:(GBOptionStringBlock)block {
	if (!block) {
		printf("\n");
		return;
	}
	NSString *string = block();
	if (self.applicationBuildFromBlockOrNil)
		string = [string stringByReplacingOccurrencesOfString:@"%APPNAME" withString:self.applicationNameFromBlockOrDefault];
	if (self.applicationVersionFromBlockOrNil)
		string = [string stringByReplacingOccurrencesOfString:@"%APPVERSION" withString:self.applicationVersionFromBlockOrNil];
	if (self.applicationBuildFromBlockOrNil)
		string = [string stringByReplacingOccurrencesOfString:@"%APPBUILD" withString:self.applicationBuildFromBlockOrNil];
	printf("%s\n", string.UTF8String);
}

#pragma mark - Helper methods

- (void)enumerateOptions:(void(^)(OptionDefinition *definition, BOOL *stop))handler {
	[self.registeredOptions enumerateObjectsUsingBlock:^(OptionDefinition *definition, NSUInteger idx, BOOL *stop) {
		handler(definition, stop);
	}];
}

- (NSUInteger)requirements:(OptionDefinition *)definition {
	return (definition.flags & 0b11);
}

- (BOOL)isSeparator:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionSeparator) > 0);
}

- (BOOL)isOptionGroup:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionGroup) > 0);
}

- (BOOL)isOptionGroupEnd:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionInternalEndGroup) > 0);
}

- (BOOL)isCmdLine:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionNoCmdLine) == 0);
}

- (BOOL)isPrint:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionNoPrint) == 0);
}

- (BOOL)isHelp:(OptionDefinition *)definition {
	return ((definition.flags & GBOptionNoHelp) == 0);
}

@end

#pragma mark - 

@implementation GBCommandLineParser (GBOptionsHelper)

- (void)registerOptions:(GBOptionsHelper *)options {
	[options registerOptionsToCommandLineParser:self];
}

@end
