//
//  GBGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBHTMLOutputGenerator.h"
#import "GBDocSetOutputGenerator.h"
#import "GBDocSetFinalizeGenerator.h"
#import "GBDocSetInstallGenerator.h"
#import "GBDocSetPublishGenerator.h"
#import "GBGenerator.h"

@interface GBGenerator ()

- (void)setupGeneratorStepsWithStore:(id)store;
- (void)runGeneratorStepsWithStore:(id)store;
@property (readonly) NSMutableArray *outputGenerators;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;

@end

#pragma mark -

@implementation GBGenerator

#pragma mark Initialization & disposal

+ (id)generatorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing generator with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Generation handling

- (void)generateOutputFromStore:(id)aStore {
	NSParameterAssert(aStore != nil);
	GBLogInfo(@"Generating output from parsed objects...");
	[self setupGeneratorStepsWithStore:aStore];
	[self runGeneratorStepsWithStore:aStore];
}

- (void)setupGeneratorStepsWithStore:(id)store {
	// Setups all output generators. The order of these is crucial as they are invoked in the order added to the list. This forms a dependency where each next generator can use
	GBLogDebug(@"Initializing generation steps...");
	if (!self.settings.createHTML) return;
	[self.outputGenerators addObject:[GBHTMLOutputGenerator generatorWithSettingsProvider:self.settings]];
	if (!self.settings.createDocSet) return;
	[self.outputGenerators addObject:[GBDocSetOutputGenerator generatorWithSettingsProvider:self.settings]];
	[self.outputGenerators addObject:[GBDocSetFinalizeGenerator generatorWithSettingsProvider:self.settings]];
	if (self.settings.installDocSet) {
        [self.outputGenerators addObject:[GBDocSetInstallGenerator generatorWithSettingsProvider:self.settings]];
    }
	if (!self.settings.publishDocSet) return;
	[self.outputGenerators addObject:[GBDocSetPublishGenerator generatorWithSettingsProvider:self.settings]];
}

- (void)runGeneratorStepsWithStore:(id)aStore {
	GBLogDebug(@"Running generation steps...");
	NSUInteger stepsCount = [self.outputGenerators count];
	if (stepsCount == 0) {
		GBLogNormal(@"No generation step defined, ending.");
		return;
	}
	
	__block GBOutputGenerator *previous = nil;
	[self.outputGenerators enumerateObjectsUsingBlock:^(GBOutputGenerator *generator, NSUInteger idx, BOOL *stop) {		
		NSError *error = nil;
		NSUInteger index = idx + 1;
		GBLogVerbose(@"Generation step %ld/%ld: Running %@...", index, stepsCount, [generator className]);
		generator.previousGenerator = previous;
		if (![generator copyTemplateFilesToOutputPath:&error]) {
			GBLogNSError(error, @"Generation step %ld/%ld failed: %@ failed copying template files to output, aborting!", index, stepsCount, [generator className]);
			*stop = YES;
			return;
		}
		if (![generator generateOutputWithStore:aStore error:&error]) {
			GBLogNSError(error, @"Generation step %ld/%ld failed: %@ failed generating output, aborting!", index, stepsCount, [generator className]);
			*stop = YES;
			return;
		}
		previous = generator;
	}];
}

#pragma mark Template files handling

- (NSMutableArray *)outputGenerators {
	static NSMutableArray *result = nil;
	if (!result) {
		GBLogDebug(@"Initializing output generators array...");
		result = [[NSMutableArray alloc] init];
	}
	return result;
}

#pragma mark Properties

@synthesize settings;
@synthesize store;

@end
