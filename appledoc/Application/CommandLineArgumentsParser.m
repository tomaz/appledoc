//
//  CommandLineArgumentsParser.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import <getopt.h>
#import "CommandLineArgumentsParser.h"

const struct GBCommandLineKeys {
	__unsafe_unretained NSString *longOption;
	__unsafe_unretained NSString *shortOption;
	__unsafe_unretained NSString *requirement;
} GBCommandLineKeys = {
	.longOption = @"long",
	.shortOption = @"short",
	.requirement = @"requirement",
};

const struct GBCommandLineArgumentResults GBCommandLineArgumentResults = {
	.missingValue = @"missing-value",
	.unknownArgument = @"unknown-argument",
};

#pragma mark -

@interface CommandLineArgumentsParser ()
- (NSData *)optionsDataFromOptions:(NSDictionary *)source;
- (NSString *)shortOptionsStringFromOptions:(NSDictionary *)options;
- (BOOL)isShortValueUserDefined:(int)value;
@property (nonatomic, strong) NSMutableDictionary *parsedOptions;
@property (nonatomic, strong) NSMutableArray *parsedArguments;
@property (nonatomic, strong) NSMutableDictionary *registeredOptions;
@property (nonatomic, assign) int lastInternalShortOption;
@end

#pragma mark -

@implementation CommandLineArgumentsParser

@synthesize parsedOptions;
@synthesize parsedArguments;
@synthesize registeredOptions;
@synthesize lastInternalShortOption;
@synthesize logParsingErrors;

#pragma mark - Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.registeredOptions = [NSMutableDictionary dictionary];
		self.parsedOptions = [NSMutableDictionary dictionary];
		self.parsedArguments = [NSMutableArray array];
		self.lastInternalShortOption = 256;
	}
	return self;
}

#pragma mark - Options registration

- (void)registerOption:(NSString *)longOption shortcut:(char)shortOption requirement:(GBCommandLineValueRequirement)requirement {
	int shortValue = (shortOption > 0) ? shortOption : self.lastInternalShortOption++;
	NSMutableDictionary *data = [NSMutableDictionary dictionary];
	[data setObject:longOption forKey:GBCommandLineKeys.longOption];
	[data setObject:[NSNumber numberWithInt:shortValue] forKey:GBCommandLineKeys.shortOption];
	[data setObject:[NSNumber numberWithInt:requirement] forKey:GBCommandLineKeys.requirement];
	[self.registeredOptions setObject:data forKey:[NSNumber numberWithInt:shortValue]];
}

- (void)registerOption:(NSString *)longOption requirement:(GBCommandLineValueRequirement)requirement {
	[self registerOption:longOption shortcut:0 requirement:requirement];
}

- (void)registerSwitch:(NSString *)longOption shortcut:(char)shortOption {
	[self registerOption:longOption shortcut:shortOption requirement:GBCommandLineValueNone];
}

- (void)registerSwitch:(NSString *)longOption {
	[self registerSwitch:longOption shortcut:0];
}

#pragma mark - Options parsing

- (BOOL)parseOptionsUsingDefaultArgumentsWithBlock:(GBCommandLineArgumentParseBlock)handler {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSArray *arguments = [processInfo arguments];
    NSString *command = [processInfo processName];
	return [self parseOptionsWithArguments:arguments commandLine:command block:handler];
}

- (BOOL)parseOptionsWithArguments:(NSArray *)arguments commandLine:(NSString *)cmd block:(GBCommandLineArgumentParseBlock)handler {
    int argc = [arguments count] + 1;
    char **argv = alloca(sizeof(char *)*argc);
	argv[0] = (char *)[cmd UTF8String];
	[arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger idx, BOOL *stop) {
		argv[idx + 1] = (char *)[argument UTF8String];
	}];
    argv[argc - 1] = 0;
	return [self parseOptionsWithArguments:argv count:argc block:handler];
}

- (BOOL)parseOptionsWithArguments:(char **)argv count:(int)argc block:(GBCommandLineArgumentParseBlock)handler {
	[self.parsedOptions removeAllObjects];
	[self.parsedArguments removeAllObjects];
	
	// Prepare input arguments for getopt_long
	NSString *shortOptions = [self shortOptionsStringFromOptions:self.registeredOptions];
	NSData *optionsData = [self optionsDataFromOptions:self.registeredOptions];
	struct option *options = (struct option *)[optionsData bytes];
	const char *shortcuts = [shortOptions UTF8String];
	
	// Parse given options.
	opterr = self.logParsingErrors ? 1 : 0;
	int option = 0;
	BOOL stop = NO;
	BOOL result = YES;
	while (YES) {
		option = getopt_long(argc, argv, shortcuts, options, NULL);
		if (option == -1) break;

		NSNumber *optionNumber = [NSNumber numberWithInt:option];
		NSDictionary *data = [self.registeredOptions objectForKey:optionNumber];
		NSString *argument = [data objectForKey:GBCommandLineKeys.longOption];
		NSString *value = nil;
		
		if (option == ':') {
			value = GBCommandLineArgumentResults.missingValue;
			result = NO;
		} else if (option == '?') {
			argument = [NSString stringWithUTF8String:argv[optind - 1]];
			value = GBCommandLineArgumentResults.unknownArgument;
			result = NO;
		} else {
			value = [NSString stringWithUTF8String:optarg];
			[self.parsedOptions setObject:value forKey:argument];
		}
		
		handler(argument, value, &stop);
		if (stop) break;
	}
	if (stop) return NO;
	
	// Whatever remaining options are there, assume these are arguments.
	int index = optind;
	while (index < argc) {
		NSString *argument = [NSString stringWithUTF8String:argv[index]];
		[self.parsedArguments addObject:argument];
		index++;
	}
	
	return result;
}

#pragma mark - Helper methods

- (NSData *)optionsDataFromOptions:(NSDictionary *)source {
	NSMutableData *result = [NSMutableData data];
	[source.allValues enumerateObjectsUsingBlock:^(NSDictionary *sourceData, NSUInteger idx, BOOL *stop) {
		NSString *longName = [sourceData objectForKey:GBCommandLineKeys.longOption];
		NSNumber *shortName = [sourceData objectForKey:GBCommandLineKeys.shortOption];
		NSNumber *requirement = [sourceData objectForKey:GBCommandLineKeys.requirement];

		struct option optionData;
		optionData.flag = NULL;
		optionData.name = [longName UTF8String];
		optionData.val = [shortName intValue];
		switch (requirement.unsignedIntegerValue) {
			case GBCommandLineValueRequired: optionData.has_arg = required_argument; break;
			case GBCommandLineValueOptional: optionData.has_arg = optional_argument; break;
			default: optionData.has_arg = no_argument; break;
		}
		
		[result appendBytes:&optionData length:sizeof(optionData)];
	}];
	return result;
}

- (NSString *)shortOptionsStringFromOptions:(NSDictionary *)options {
	// Prepares short options string for getopt_long function.
	NSMutableString *result = [NSMutableString string];
	[options.allValues enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
		GBCommandLineValueRequirement requirement = [[data objectForKey:GBCommandLineKeys.requirement] unsignedIntegerValue];
		int shortValue = [[data objectForKey:GBCommandLineKeys.shortOption] intValue];
		[result appendFormat:@"%c", shortValue];
		if ([self isShortValueUserDefined:shortValue]) {
			if (requirement == GBCommandLineValueRequired)
				[result appendString:@":"];
			else if (requirement == GBCommandLineValueOptional)
				[result appendFormat:@"::"];
		}
	}];
	return result;
}

- (BOOL)isShortValueUserDefined:(int)value {
	return (value < 256);
}

#pragma mark - Getting parsed results

- (id)valueForOption:(NSString *)longOption {
	return [self.parsedOptions objectForKey:longOption];
}

- (NSArray *)arguments {
	return [self.parsedArguments copy];
}

@end
