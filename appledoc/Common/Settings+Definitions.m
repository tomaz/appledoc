//
//  Settings+Definitions.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/14/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//
#import "CommandLineArgumentsParser.h"
#import "Settings+Definitions.h"

GBOptionDefinition GBSettingDefinitions[] = {
	{ 0,	nil,					@"PROJECT INFO",											GBOptionSeparator|GBOptionNoCmdLine },
	{ 'p',	@"project-name",		@"Project name",											GBValueRequired },
	{ 'v',	@"project-version",		@"Project version",											GBValueRequired },
	{ 'c',	@"company-name",		@"Company name",											GBValueRequired },
	{ 0,	@"company-id",			@"Company UTI (i.e. reverse DNS name)",						GBValueRequired },
	
	{ 0,	nil,					@"PATHS",													GBOptionSeparator|GBOptionNoCmdLine },
	{ 0,	@"input",				@"Array of input paths for global and project settings",	GBOptionNoCmdLine|GBOptionInvisible },

	{ 0,	nil,					@"MISCELLANEOUS",											GBOptionSeparator|GBOptionNoCmdLine },
	{ 0,	@"print-settings",		@"Print settings for current run",							GBValueNone },
	{ 0,	@"version",				@"Display version and exit",								GBValueNone|GBOptionNoPrint },
	{ '?',	@"help",				@"Display this help and exit",								GBValueNone|GBOptionNoPrint },

	{ 0,	nil, nil, 0 }
};

#pragma mark - Various helper functions

inline void GBEnumerateOptions(void(^handler)(GBOptionDefinition *option, BOOL *stop)) {
	GBOptionDefinition *option = GBSettingDefinitions;
	BOOL stop = NO;
	while (option->longOption || option->description) {
		handler(option, &stop);
		if (stop) break;
		option++;
	}
}

inline NSUInteger GBOptionRequirements(GBOptionDefinition *option) {
	return (option->flags & 0b11);
}

inline BOOL GBOptionIsSeparator(GBOptionDefinition *option) {
	return ((option->flags & GBOptionSeparator) > 0);
}

inline BOOL GBOptionIsCmdLine(GBOptionDefinition *option) {
	return ((option->flags & GBOptionNoCmdLine) == 0);
}

inline BOOL GBOptionIsPrint(GBOptionDefinition *option) {
	return ((option->flags & GBOptionNoPrint) == 0);
}

inline BOOL GBOptionIsHelp(GBOptionDefinition *option) {
	return ((option->flags & GBOptionNoHelp) == 0);
}
