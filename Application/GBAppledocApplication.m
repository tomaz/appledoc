//
//  GBAppledocApplication.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "DDCliUtil.h"
#import "DDGetoptLongParser.h"
#import "GBAppledocApplication.h"

static NSString *kGBArgLogFormat = @"logformat";
static NSString *kGBArgVerbose = @"verbose";
static NSString *kGBArgVersion = @"version";
static NSString *kGBArgHelp = @"help";

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)validateArguments:(NSArray *)arguments;
@property (assign) NSString *logformat;
@property (assign) NSString *verbose;
@property (assign) BOOL version;
@property (assign) BOOL help;

@end

#pragma mark -

@interface GBAppledocApplication (UsagePrintout)

- (void)printVersion;
- (void)printArguments;
- (void)printHelp;
- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description;

@end

#pragma mark -

@implementation GBAppledocApplication

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.logformat = @"1";
		self.verbose = @"2";
	}
	return self;
}

#pragma mark DDCliApplicationDelegate implementation

- (int)application:(DDCliApplication *)app runWithArguments:(NSArray *)arguments {
	if (self.help) {
		[self printHelp];
		return EXIT_SUCCESS;
	}
	if (self.version) {
		[self printHelp];
		return EXIT_SUCCESS;
	}
	
	@try {
		[self validateArguments:arguments];
		[self initializeLoggingSystem];
		GBLogNormal(@"Starting...");
		GBLogNormal(@"Finished.");
	}
	@catch (NSException * e) {
		return EXIT_FAILURE;
	}
	
	return EXIT_SUCCESS;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption options[] = {
		{ kGBArgLogFormat,				'f',	DDGetoptRequiredArgument },
		{ kGBArgVerbose,				'v',	DDGetoptRequiredArgument },
		{ kGBArgVersion,				0,		DDGetoptNoArgument },
		{ kGBArgHelp,					'h',	DDGetoptNoArgument },
		{ nil,							0,		0 },
	};
	[optionParser addOptionsFromTable:options];
}

#pragma mark Application handling

- (void)initializeLoggingSystem {
	id formatter = [GBLog logFormatterForLogFormat:self.logformat];
	[[DDConsoleLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[DDConsoleLogger sharedInstance]];
	[GBLog setLogLevelFromVerbose:self.verbose];
	[formatter release];
}

- (void)validateArguments:(NSArray *)arguments {
	if ([arguments count] == 0) [NSException raise:@"ArgumentsMissingException" format:@"At least one argument is required"];
}

#pragma mark Properties

@synthesize logformat;
@synthesize verbose;
@synthesize version;
@synthesize help;

@end

#pragma mark -

@implementation GBAppledocApplication (UsagePrintout)

- (void)printVersion {
	ddprintf(@"%@ version: %@\n", DDCliApp, @"2.0 pre-alpha");
}

- (void)printArguments {
	ddprintf(@"At least one directory or file argument is required.\n");
	ddprintf(@"Try '%@ --help' for more information.\n", DDCliApp);
}

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]
	ddprintf(@"Usage: %@ [OPTIONS] <source dirs or files>\n", DDCliApp);
	ddprintf(@"\n");
	PRINT_USAGE(@"-f,", kGBArgLogFormat, @"<format>", @"Log format [0-4]");
	PRINT_USAGE(@"-v,", kGBArgVerbose, @"<level>", @"Log verbosity level [0-6]");
	PRINT_USAGE(@"   ", kGBArgVersion, @"", @"Display version and exit");
	PRINT_USAGE(@"-h,", kGBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
}

- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description {
	while([aLong length] + [argument length] < 20) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end

