//
//  GBAppledocApplication.m
//  appledoc
//
//  Created by Tomaz Kragelj on 22.7.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "DDCliUtil.h"
#import "DDGetoptLongParser.h"
#import "GBParser.h"
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
		[self printVersion];
		return EXIT_SUCCESS;
	}
	
	@try {
		[self validateArguments:arguments];
		[self initializeLoggingSystem];
		
//		GBLogNormal(@"Parsing source files...");
//		GBParser *parser = [[GBParser alloc] initWithSettingsProvider:self];
//		[parser parseObjectsFromPaths:arguments];
//		
//		GBLogNormal(@"Processing parsed data...");
//		GBProcessor *processor = [[GBProcessor alloc] init];
//		[processor processObjectsFromParser:parser];
//		
//		GBLogNormal(@"Generating output...");
//		GBGenerator *generator = [[GBGenerator alloc] init];
//		[generator generateOutputFromProcessor:processor];
		
		GBLogNormal(@"Finished.");
	}
	@catch (NSException *e) {
		GBLogException(e, @"Oops, something went wrong...");
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

- (void)printHelp {
#define PRINT_USAGE(short,long,arg,desc) [self printHelpForShortOption:short longOption:long argument:arg description:desc]
	ddprintf(@"Usage: %@ [OPTIONS] <paths to source dirs or files>\n", DDCliApp);
	ddprintf(@"\n");
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
	ddprintf(@"\n");
	ddprintf(@"We'd like to thank all authors for their contribution!");
}

- (void)printHelpForShortOption:(NSString *)aShort longOption:(NSString *)aLong argument:(NSString *)argument description:(NSString *)description {
	while([aLong length] + [argument length] < 20) argument = [argument stringByAppendingString:@" "];
	ddprintf(@"  %@ --%@ %@ %@\n", aShort, aLong, argument, description);
}

@end

