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
	GBLogDebug(@"Initializing generation steps...");
	[self.outputGenerators addObject:[GBHTMLOutputGenerator generatorWithSettingsProvider:self.settings]];
}

- (void)runGeneratorStepsWithStore:(id<GBStoreProviding>)store {
	GBLogDebug(@"Running generation steps...");
	NSUInteger stepsCount = [self.outputGenerators count];
	[self.outputGenerators enumerateObjectsUsingBlock:^(GBOutputGenerator *generator, NSUInteger idx, BOOL *stop) {
		NSError *error = nil;
		GBLogVerbose(@"Step %ld/%ld: Running %@...", idx, stepsCount, [generator className]);
		if (![generator copyTemplateFilesToOutputPath:&error]) {
			GBLogNSError(error, @"Step %ld/%ld failed: %@ failed copying template files to output, aborting!", idx, stepsCount, [generator className]);
			*stop = YES;
			return;
		}
		if (![generator generateOutputWithStore:store error:&error]) {
			GBLogNSError(error, @"Step %ld/%ld failed: %@ failed generaing output, aborting!", idx, stepsCount, [generator className]);
			*stop = YES;
			return;
		}
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
