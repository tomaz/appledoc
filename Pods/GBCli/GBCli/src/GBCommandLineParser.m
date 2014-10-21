//
//  GBCommandLineParser.m
//  GBCli
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "GBPrint.h"
#import "GBSettings.h"
#import "GBCommandLineParser.h"

static NSString * const GBCommandLineLongOptionKey = @"long";
static NSString * const GBCommandLineShortOptionKey = @"short";
static NSString * const GBCommandLineRequirementKey = @"requirement";
static NSString * const GBCommandLineOptionGroupKey = @"group"; // this is returned while parsing to indicate an option group was detected.
static NSString * const GBCommandLineNotAnOptionKey = @"not-an-option"; // this is returned while parsing to indicate an argument was detected.

#pragma mark -

@interface GBCommandLineParser ()
- (NSDictionary *)optionDataForOption:(NSString *)shortOrLongName value:(NSString **)value;
- (BOOL)isShortOrLongOptionName:(NSString *)value;
@property (nonatomic, strong) GBSettings *settings; // optional (only required by simplified parsing methods)
@property (nonatomic, strong) NSMutableDictionary *parsedOptions;
@property (nonatomic, strong) NSMutableArray *parsedArguments;
@property (nonatomic, strong) NSMutableDictionary *registeredOptionsByLongNames;
@property (nonatomic, strong) NSMutableDictionary *registeredOptionsByShortNames;
@property (nonatomic, strong) NSMutableDictionary *registeredOptionGroupsByNames;
@property (nonatomic, strong) NSMutableSet *currentOptionsGroupOptions; // this is used both while registering and while parsing arguments
@property (nonatomic, copy) NSString *currentOptionsGroupName; // used while parsing
@end

#pragma mark -

@implementation GBCommandLineParser

@synthesize parsedOptions;
@synthesize parsedArguments;
@synthesize registeredOptionsByLongNames;
@synthesize registeredOptionsByShortNames;

#pragma mark - Initialization & disposal

- (instancetype)init {
	self = [super init];
	if (self) {
		self.registeredOptionsByLongNames = [NSMutableDictionary dictionary];
		self.registeredOptionsByShortNames = [NSMutableDictionary dictionary];
		self.registeredOptionGroupsByNames = [NSMutableDictionary dictionary];
		self.parsedOptions = [NSMutableDictionary dictionary];
		self.parsedArguments = [NSMutableArray array];
	}
	return self;
}

#pragma mark - Options registration

- (void)beginRegisterOptionGroup:(NSString *)name {
	self.currentOptionsGroupOptions = self.registeredOptionGroupsByNames[name];

	// Warn if we already have the given group.
	if (self.registeredOptionGroupsByNames[name]) {
		fprintf(stderr, "Group %s is already registered!", [name UTF8String]);
		return;
	}
	
	// Create options group data into which we'll be registering options from now on.
	self.currentOptionsGroupOptions = [NSMutableSet set];
	self.registeredOptionGroupsByNames[name] = self.currentOptionsGroupOptions;
}

- (void)endRegisterOptionGroup {
	self.currentOptionsGroupName = nil;
	self.currentOptionsGroupOptions = nil;
}

- (void)registerOption:(NSString *)longOption shortcut:(char)shortOption requirement:(GBValueRequirements)requirement {
	// Register option data.
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	data[GBCommandLineLongOptionKey] = longOption;
	data[GBCommandLineRequirementKey] = @(requirement);
	self.registeredOptionsByLongNames[longOption] = data;
	[self.currentOptionsGroupOptions addObject:longOption];
	
	// Register short option data if needed.
	if (shortOption > 0) {
		NSString *shortOptionKey = [NSString stringWithFormat:@"%c", shortOption];
		data[GBCommandLineShortOptionKey] = @(shortOption);
		self.registeredOptionsByShortNames[shortOptionKey] = data;
	}

	// If this is a swich, register negative variant (i.e. if the option is named --option, negative form is --no-option). Note that negative variant doesn't support short code!
	if (requirement == GBValueNone) {		
		NSMutableDictionary *negativeVariantData = [NSMutableDictionary dictionary];
		NSString *negativeVariantLongOption = [NSString stringWithFormat:@"no-%@", longOption];
		negativeVariantData[GBCommandLineLongOptionKey] = negativeVariantLongOption;
		negativeVariantData[GBCommandLineRequirementKey] = @(requirement);
		self.registeredOptionsByLongNames[negativeVariantLongOption] = negativeVariantData;
		[self.currentOptionsGroupOptions addObject:negativeVariantData];
	}
}

- (void)registerOption:(NSString *)longOption requirement:(GBValueRequirements)requirement {
	[self registerOption:longOption shortcut:0 requirement:requirement];
}

- (void)registerSwitch:(NSString *)longOption shortcut:(char)shortOption {
	[self registerOption:longOption shortcut:shortOption requirement:GBValueNone];
}

- (void)registerSwitch:(NSString *)longOption {
	[self registerSwitch:longOption shortcut:0];
}

#pragma mark - Options parsing - Simple methods with default behavior

- (void)registerSettings:(GBSettings *)settings {
	self.settings = settings;
}

- (BOOL)parseOptionsUsingDefaultArguments {
	[self validateSimplifiedOptionsWithSelector:_cmd];
	return [self parseOptionsUsingDefaultArgumentsWithBlock:[self simplifiedOptionsParserBlock]];
}

- (BOOL)parseOptionsWithArguments:(char **)argv count:(int)argc {
	[self validateSimplifiedOptionsWithSelector:_cmd];
	return [self parseOptionsWithArguments:argv count:argc block:[self simplifiedOptionsParserBlock]];
}

- (BOOL)parseOptionsWithArguments:(NSArray *)arguments commandLine:(NSString *)cmd {
	[self validateSimplifiedOptionsWithSelector:_cmd];
	return [self parseOptionsWithArguments:arguments commandLine:cmd block:[self simplifiedOptionsParserBlock]];
}

- (GBCommandLineParseBlock)simplifiedOptionsParserBlock {
	return ^(GBParseFlags flags, NSString *argument, id value, BOOL *stop) {
		switch (flags) {
			case GBParseFlagUnknownOption:
				gbfprintln(stderr, @"Unknown command line option %@, try --help!", argument);
				break;
			case GBParseFlagMissingValue:
				gbfprintln(stderr, @"Missing value for command line option %s, try --help!", argument);
				break;
			case GBParseFlagWrongGroup:
				gbfprintln(stderr, @"Invalid option %@ for group %@!", argument, self.currentOptionsGroupName);
				break;
			case GBParseFlagArgument:
				[self.settings addArgument:value];
				break;
			case GBParseFlagOption:
				[self.settings setObject:value forKey:argument];
				break;
		}
	};
}

- (void)validateSimplifiedOptionsWithSelector:(SEL)sel {
	NSAssert(self.settings != nil, @"%@ requires you to supply GBSettings instance via registerSettings: method!", NSStringFromSelector(sel));
}

#pragma mark - Options parsing - Methods with customizations

- (BOOL)parseOptionsUsingDefaultArgumentsWithBlock:(GBCommandLineParseBlock)handler {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *command = [processInfo processName];
    NSMutableArray *arguments = [[processInfo arguments] mutableCopy];
	[arguments removeObjectAtIndex:0];
	return [self parseOptionsWithArguments:arguments commandLine:command block:handler];
}

- (BOOL)parseOptionsWithArguments:(char **)argv count:(int)argc block:(GBCommandLineParseBlock)handler {
	if (argc == 0) return YES;
	NSString *command = [NSString stringWithUTF8String:argv[0]];
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:argc - 1];
	for (int i=1; i<argc; i++) {
		NSString *argument = [NSString stringWithUTF8String:argv[i]];
		[arguments addObject:argument];
	}
	return [self parseOptionsWithArguments:arguments commandLine:command block:handler];
}

- (BOOL)parseOptionsWithArguments:(NSArray *)arguments commandLine:(NSString *)cmd block:(GBCommandLineParseBlock)handler {
	// Cleanup in case parsing is invoked multiple times.
	self.currentOptionsGroupOptions = nil;
	[self.parsedOptions removeAllObjects];
	[self.parsedArguments removeAllObjects];

	BOOL result = YES;
	BOOL stop = NO;
	
	// Parse options (options start with -- or -).
	NSUInteger index = 0;
	while (index < [arguments count]) {
		id value = nil;
		NSString *input = [arguments objectAtIndex:index];
		NSDictionary *data = [self optionDataForOption:input value:&value];
		if (data == (id)GBCommandLineNotAnOptionKey) break; // no more options, only arguments left...
		if (data == (id)GBCommandLineOptionGroupKey) {
			// If this is group name, continue with next option...
			handler(GBParseFlagOption, input, @YES, &stop);
			index++;
			continue;
		}
		
		NSString *name = data[GBCommandLineLongOptionKey];
		GBParseFlags flags = GBParseFlagOption;
		
		if (data == nil) {
			// If no registered option matches given one, notify observer.
			name = input;
			flags = GBParseFlagUnknownOption;
			result = NO;
		} else if (self.currentOptionsGroupOptions && ![self.currentOptionsGroupOptions containsObject:name]) {
			// If name of the option is not registered for the current group, notify observer.
			name = input;
			flags = GBParseFlagWrongGroup;
			result = NO;
		} else {
			// Prepare the value or notify about problem with it.
			GBValueRequirements requirement = [data[GBCommandLineRequirementKey] unsignedIntegerValue];
			switch (requirement) {
				case GBValueRequired:
					// Option requires value: check next option and if it "looks like" an option (i.e. starts with -- or - or is one of option group names), notify about missing value. Also notify about missing value if this is the last option. If we already have the value (via --name=value syntax), no need to search.
					if (!value) {
						if (index < arguments.count - 1) {
							value = [arguments objectAtIndex:index + 1];
							if ([self isShortOrLongOptionName:value]) {
								flags = GBParseFlagMissingValue;
							} else if ([self isOptionGroupName:value]) {
								flags = GBParseFlagMissingValue;
							} else {
								index++;
							}
						} else {
							flags = GBParseFlagMissingValue;
						}
					}
					break;
				case GBValueOptional:
					// Options can have optional value: check next option and if it "looks like" a value (i.e. doesn't start with -- or -), use it. Otherwie assume YES (the same if there's no more option). If we already have the value (via --name=value syntax), no need to search.
					if (!value) {
						if (index < arguments.count - 1) {
							value = [arguments objectAtIndex:index + 1];
							if ([self isShortOrLongOptionName:value]) {
								value = @YES;
							} else if ([self isOptionGroupName:value]) {
								value = @YES;
							} else {
								index++;
							}
						} else {
							value = @YES;
						}
					}
					break;
				default:
					// Option is a boolean "switch": return either YES or NO, depending on the switch name (--option or --no-option). Note that we always report positive option name (we only use negative form internally)! If we already have a valud (via --name=value syntax), convert value to boolean.
					if ([input hasPrefix:@"--no-"]) {
						if (value) {
							BOOL cmdLineValue = [value boolValue];
							value = @(!cmdLineValue);
						} else {
							value = @NO;
						}
					} else {
						if (value) {
							BOOL cmdLineValue = [value boolValue];
							value = @(cmdLineValue);
						} else {
							value = @YES;
						}
					}
					break;
			}
		}
		
		// Prepare remaining parameters and notify observer. If observer stops the operation, quit immediately.
		handler(flags, name, value, &stop);
		if (stop) return NO;
		
		// Remember parsed option and continue with next one.
		if (value) [self.parsedOptions setObject:value forKey:name];
		index++;
	}
	
	// Prepare arguments (arguments are command line options after options).
	while (index < arguments.count) {
		NSString *input = [arguments objectAtIndex:index];
		[self.parsedArguments addObject:input];
		handler(GBParseFlagArgument, nil, input, &stop);
		if (stop) return NO;
		index++;
	}
	
	return result;
}

#pragma mark - Helper methods

- (NSDictionary *)optionDataForOption:(NSString *)shortOrLongName value:(NSString **)value {
	NSString *name = nil;
	NSDictionary *options = nil;
	
	// Extract the option name.
	if ([shortOrLongName hasPrefix:@"--"]) {
		name = [shortOrLongName substringFromIndex:2];
		options = self.registeredOptionsByLongNames;
	} else if ([shortOrLongName hasPrefix:@"-"]) {
		name = [shortOrLongName substringFromIndex:1];
		options = self.registeredOptionsByShortNames;
	} else if ([self isOptionGroupName:shortOrLongName]) {
		self.currentOptionsGroupName = shortOrLongName;
		self.currentOptionsGroupOptions = self.registeredOptionGroupsByNames[shortOrLongName];
		return (id)GBCommandLineOptionGroupKey;
	} else {
		return (id)GBCommandLineNotAnOptionKey;
	}
	
	// If the name includes value, extract that too.
	NSRange valueRange = [name rangeOfString:@"=" options:NSBackwardsSearch];
	if (valueRange.location != NSNotFound) {
		if (value) *value = [name substringFromIndex:valueRange.location + 1];
		name = [name substringToIndex:valueRange.location];
	}
	return [options objectForKey:name];
}

- (BOOL)isShortOrLongOptionName:(NSString *)value {
	if ([value hasPrefix:@"--"]) return YES;
	if ([value hasPrefix:@"-"]) return YES;
	return NO;
}

- (BOOL)isOptionGroupName:(NSString *)value {
	if (!self.registeredOptionGroupsByNames) return NO;
	if (!self.registeredOptionGroupsByNames[value]) return NO;
	return YES;
}

#pragma mark - Getting parsed results

- (id)valueForOption:(NSString *)longOption {
	return [self.parsedOptions objectForKey:longOption];
}

- (NSArray *)arguments {
	return [self.parsedArguments copy];
}

@end
