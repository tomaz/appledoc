//
//  Appledoc.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommandLineArgumentsParser.h"
#import "Appledoc.h"

@interface Appledoc ()
@property (nonatomic, strong) Settings *settings;
@end

#pragma mark -

@implementation Appledoc

@synthesize settings = _settings;
@synthesize commandLineParser = _commandLineParser;

#pragma mark - Initialization & disposal

- (id)init {
	self = [super init];
	return self;
}

#pragma mark - Preparing for run

- (void)setupSettingsFromCmdLineArgs:(char **)argv count:(int)argc {
	// Initialize the settings stack.
	Settings *factoryDefaults = [Settings settingsWithName:@"Factory" parent:nil];
	Settings *globalSettings = [Settings settingsWithName:@"Global" parent:factoryDefaults];
	Settings *projectSettings = [Settings settingsWithName:@"Project" parent:globalSettings];
	Settings *settings = [Settings settingsWithName:@"CmdLine" parent:projectSettings];
	
	// Parse command line.
	[settings registerOptionsToCommandLineParser:self.commandLineParser];
	[self.commandLineParser parseOptionsWithArguments:argv count:argc block:^(NSString *argument, id value, BOOL *stop) {
	}];
	
	self.settings = settings;
}

#pragma mark - Properties

- (CommandLineArgumentsParser *)commandLineParser {
	if (_commandLineParser) return _commandLineParser;
	_commandLineParser = [[CommandLineArgumentsParser alloc] init];
	return _commandLineParser;
}

@end
