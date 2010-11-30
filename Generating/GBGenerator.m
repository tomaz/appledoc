//
//  GBGenerator.m
//  appledoc
//
//  Created by Tomaz Kragelj on 29.9.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBHTMLOutputGenerator.h"
#import "GBDocSetOutputGenerator.h"
#import "GBGenerator.h"

@interface GBGenerator ()

- (void)setupGeneratorStepsWithStore:(id<GBStoreProviding>)store;
- (void)runGeneratorStepsWithStore:(id<GBStoreProviding>)store;
@property (readonly) NSMutableArray *outputGenerators;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBGenerator

#pragma mark Initialization & disposal

+ (id)generatorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing generator with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
	}
	return self;
}

#pragma mark Generation handling

- (void)generateOutputFromStore:(id<GBStoreProviding>)store {
	NSParameterAssert(store != nil);
	GBLogInfo(@"Generating output from parsed objects...");
	[self setupGeneratorStepsWithStore:store];
	[self runGeneratorStepsWithStore:store];
}

- (void)setupGeneratorStepsWithStore:(id<GBStoreProviding>)store {
	// Setups all output generators. The order of these is crucial as they are invoked in the order added to the list. This forms a dependency where each next generator can use
	GBLogDebug(@"Initializing generation steps...");
	[self.outputGenerators addObject:[GBHTMLOutputGenerator generatorWithSettingsProvider:self.settings]];
	[self.outputGenerators addObject:[GBDocSetOutputGenerator generatorWithSettingsProvider:self.settings]];
}

- (void)runGeneratorStepsWithStore:(id<GBStoreProviding>)store {
	GBLogDebug(@"Running generation steps...");
	NSUInteger stepsCount = [self.outputGenerators count];
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
		if (![generator generateOutputWithStore:store error:&error]) {
			GBLogNSError(error, @"Generation step %ld/%ld failed: %@ failed generaing output, aborting!", index, stepsCount, [generator className]);
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
