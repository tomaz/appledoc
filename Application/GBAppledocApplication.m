//
//  GBAppledocApplication.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "timing.h"
#import "DDCliUtil.h"
#import "DDGetoptLongParser.h"
#import "GBStore.h"
#import "GBParser.h"
#import "GBProcessor.h"
#import "GBGenerator.h"
#import "GBApplicationSettingsProvider.h"
#import "GBAppledocApplication.h"

static NSString *kGBArgIgnorePath = @"ignore";
static NSString *kGBArgLogFormat = @"logformat";
static NSString *kGBArgVerbose = @"verbose";
static NSString *kGBArgVersion = @"version";
static NSString *kGBArgHelp = @"help";

#pragma mark -

@interface GBAppledocApplication ()

- (void)initializeLoggingSystem;
- (void)validateArguments:(NSArray *)arguments;
@property (retain) GBApplicationSettingsProvider *settings;
@property (assign) NSString *logformat;
@property (assign) NSString *verbose;
@property (assign) BOOL version;
@property (assign) BOOL help;

@end

#pragma mark -

@interface GBAppledocApplication (UsagePrintout)

- (void)printVersion;
- (void)printHelp;
- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description;

@end

#pragma mark -

@implementation GBAppledocApplication

#pragma mark Initialization & disposal

- (id)init {
	self = [super init];
	if (self) {
		self.settings = [GBApplicationSettingsProvider provider];
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
		[self printVersion];
		return EXIT_SUCCESS;
	}
	
	@try {		
		[self validateArguments:arguments];
		[self initializeLoggingSystem];
		
		GBLogNormal(@"Initializing...");
		GBStore *store = [[GBStore alloc] init];		
		GBAbsoluteTime startTime = GetCurrentTime();
		
		GBLogNormal(@"Parsing source files...");
		GBParser *parser = [GBParser parserWithSettingsProvider:self.settings];
		[parser parseObjectsFromPaths:arguments toStore:store];
		GBAbsoluteTime parseTime = GetCurrentTime();
		NSUInteger timeForParsing = SubtractTime(parseTime, startTime) * 1000.0;
		GBLogInfo(@"Finished parsing in %ldms.\n", timeForParsing);
		
		GBLogNormal(@"Processing parsed data...");
		GBProcessor *processor = [GBProcessor processorWithSettingsProvider:self.settings];
		[processor processObjectsFromStore:store];
		GBAbsoluteTime processTime = GetCurrentTime();
		NSUInteger timeForProcessing = SubtractTime(processTime, parseTime) * 1000.0;
		GBLogInfo(@"Finished processing in %ldms.\n", timeForProcessing);
		
		GBLogNormal(@"Generating output...");
		GBGenerator *generator = [GBGenerator generatorWithSettingsProvider:self.settings];
		[generator generateOutputFromStore:store];
		GBAbsoluteTime generateTime = GetCurrentTime();
		NSUInteger timeForGeneration = SubtractTime(generateTime, processTime) * 1000.0;
		GBLogInfo(@"Finished generating in %ldms.\n", timeForGeneration);
		
		NSUInteger timeForEverything = timeForParsing + timeForProcessing + timeForGeneration;		
		GBLogNormal(@"Finished in %ldms.", timeForEverything);
		GBLogInfo(@"Parsing:    %ldms (%ld%%)", timeForParsing, timeForParsing * 100 / timeForEverything);
		GBLogInfo(@"Processing: %ldms (%ld%%)", timeForProcessing, timeForProcessing * 100 / timeForEverything);
		GBLogInfo(@"Generating: %ldms (%ld%%)", timeForGeneration, timeForGeneration * 100 / timeForEverything);
	}
	@catch (NSException *e) {
		GBLogException(e, @"Oops, something went wrong...");
		return EXIT_FAILURE;
	}
	
	return EXIT_SUCCESS;
}

- (void)application:(DDCliApplication *)app willParseOptions:(DDGetoptLongParser *)optionParser {
	DDGetoptOption options[] = {
		{ kGBArgIgnorePath,				'i',	DDGetoptRequiredArgument },
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
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	[GBLog setLogLevelFromVerbose:self.verbose];
	[formatter release];
}

- (void)validateArguments:(NSArray *)arguments {
	if ([arguments count] == 0) [NSException raise:@"At least one argument is required"];
	for (NSString *path in arguments) {
		if (![self.fileManager fileExistsAtPath:path]) {
			[NSException raise:@"Path or file '%@' doesn't exist!", path];
		}
	}
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Callbacks API for DDCliApplication

- (void)setIgnore:(NSString *)path {
	if ([path hasPrefix:@"*"]) path = [path substringFromIndex:1];
	[self.settings.ignoredPaths addObject:path];
}

@synthesize logformat;
@synthesize verbose;
@synthesize version;
@synthesize help;

#pragma mark Properties

@synthesize settings;

@end

#pragma mark -

@implementation GBAppledocApplication (UsagePrintout)

- (void)printVersion {
	ddprintf(@"%@ version: %@\n", DDCliApp, @"2.0 pre-alpha");
}

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", DDCliApp);
	ddprintf(@"\n");
	PRINT_USAGE(@"-i,", kGBArgIgnorePath, @"<path>", @"Ignore given path");
	PRINT_USAGE(@"-f,", kGBArgLogFormat, @"<format>", @"Log format [0-4]");
	PRINT_USAGE(@"-v,", kGBArgVerbose, @"<level>", @"Log verbosity level [0-6]");
	PRINT_USAGE(@"   ", kGBArgVersion, @"", @"Display version and exit");
	PRINT_USAGE(@"-h,", kGBArgHelp, @"", @"Display this help and exit");
	ddprintf(@"\n");
	ddprintf(@"appledoc uses the following open source components, fully or partially:\n");
	ddprintf(@"\n");
	ddprintf(@"- DDCli by Dave Dribin\n");
	ddprintf(@"- CocoaLumberjack by Robbie Hanson\n");
	ddprintf(@"- ParseKit by Todd Ditchendorf\n");
	ddprintf(@"- RegexKitLite by John Engelhart\n");
	ddprintf(@"- GRMustache by Gwendal Roué\n");
	ddprintf(@"- Timing functions from Apple examples\n");
	ddprintf(@"\n");
	ddprintf(@"We'd like to thank all authors for their contribution!");
}

- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description {
	while([aLong length] + [argument length] < 20) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end

