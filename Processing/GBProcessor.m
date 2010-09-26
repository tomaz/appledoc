//
//  GBProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProviding.h"
#import "GBStoreProviding.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"
#import "GBProcessor.h"

@interface GBProcessor ()

- (void)processClasses;
- (void)processCategories;
- (void)processProtocols;
- (void)processDataProvider:(id<GBObjectDataProviding>)provider withComment:(GBComment *)comment;
- (void)processAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)processMethodsFromProvider:(GBMethodsProvider *)provider;
- (void)processComment:(GBComment *)comment;
- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method;
@property (retain) GBCommentsProcessor *commentsProcessor;
@property (retain) id<GBObjectDataProviding> currentContext;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	NSParameterAssert([settingsProvider conformsToProtocol:@protocol(GBApplicationSettingsProviding)]);
	GBLogDebug(@"Initializing processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
		self.commentsProcessor = [GBCommentsProcessor processorWithSettingsProvider:self.settings];
	}
	return self;
}

#pragma mark Processing handling

- (void)processObjectsFromStore:(id<GBStoreProviding>)store {
	NSParameterAssert(store != nil);
	GBLogVerbose(@"Processing objects...");
	self.currentContext = nil;
	self.store = store;
	[self processClasses];
	[self processCategories];
	[self processProtocols];
}

- (void)processClasses {
	// No need to process ivars as they are not used for output.
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Processing class %@...", class);
		[self processDataProvider:class withComment:class.comment];
	}
}

- (void)processCategories {
	for (GBCategoryData *category in self.store.categories) {
		GBLogInfo(@"Processing category %@...", category);
		[self processDataProvider:category withComment:category.comment];
	}
}

- (void)processProtocols {
	for (GBProtocolData *protocol in self.store.protocols) {
		GBLogInfo(@"Processing protocol %@...", protocol);
		[self processDataProvider:protocol withComment:protocol.comment];
	}
}

#pragma mark Common data processing

- (void)processDataProvider:(id<GBObjectDataProviding>)provider withComment:(GBComment *)comment {
	// Set current context then process all data. Note that processing order is only important for nicer logging messages.
	self.currentContext = provider;
	[self processAdoptedProtocolsFromProvider:provider.adoptedProtocols];
	[self processComment:comment];
	[self processMethodsFromProvider:provider.methods];
	self.currentContext = nil;
}

- (void)processAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider {
	// This replaces known adopted protocols with real ones from the assigned store.
	NSArray *registeredProtocols = [self.store.protocols allObjects];
	for (GBProtocolData *adopted in [provider.protocols allObjects]) {
		for (GBProtocolData *registered in registeredProtocols) {
			if ([registered.nameOfProtocol isEqualToString:adopted.nameOfProtocol]) {
				GBLogDebug(@"Replacing adopted protocol %@ with data from store...", registered);
				[provider replaceProtocol:adopted withProtocol:registered];
				break;
			}
		}
	}
}

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider {
	for (GBMethodData *method in provider.methods) {
		GBLogVerbose(@"Processing method %@...", method);
		[self processComment:method.comment];
		[self processParametersFromComment:method.comment matchingMethod:method];
	}
}

#pragma mark Comments processing

- (void)processComment:(GBComment *)comment {
	if (!comment || [comment.stringValue length] == 0) return;
	GBLogDebug(@"Processing comment %@...", comment);
	[self.commentsProcessor processComment:comment withContext:self.currentContext store:self.store];
}

- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method {
	// This is where we validate comment parameters and sort them in proper order.
	if (!comment || [comment.stringValue length] == 0) return;
	GBLogDebug(@"Processing parameters from method %@ comment %@", method, comment);
	
	// Prepare names of all argument variables from the method and parameter descriptions from the comment and warn user if method defines more parameters than there are descriptions (we'll warn about the opposite later on), but continue anyway.
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:[method.methodArguments count]];
	[method.methodArguments enumerateObjectsUsingBlock:^(GBMethodArgument *argument, NSUInteger idx, BOOL *stop) {
		if (!argument.argumentVar) return;
		[names addObject:argument.argumentVar];
	}];
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[comment.parameters count]];
	[comment.parameters enumerateObjectsUsingBlock:^(GBCommentArgument *parameter, NSUInteger idx, BOOL *stop) {
		[parameters setObject:parameter forKey:parameter.argumentName];
	}];
	if ([names count] > [parameters count]) {
		NSMutableString *description = [NSMutableString string];
		[names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
			if ([parameters objectForKey:name]) return;
			if ([description length] > 0) [description appendString:@", "];
			[description appendString:name];
		}];
		GBLogWarn(@"%@: %ld parameter descriptions (%@) missing for method %@!", comment.sourceInfo, [names count], description, method);
	}
	
	// Sort the parameters in the same order as in the method. Warn if any parameter is not found. Also warn if there are more parameters in the comment than the method defines. Note that we still add these descriptions to the end of the sorted list!
	NSMutableArray *sorted = [NSMutableArray arrayWithCapacity:[parameters count]];
	[names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
		GBCommentArgument *parameter = [parameters objectForKey:name];
		if (!parameter) {
			GBLogWarn(@"%@: Parameter %@ description missing for method %@!", comment.sourceInfo, name, method);
			return;
		}
		[sorted addObject:parameter];
		[parameters removeObjectForKey:name];
	}];
	if ([parameters count] > 0) {
		NSMutableString *description = [NSMutableString string];
		[[parameters allValues] enumerateObjectsUsingBlock:^(GBCommentArgument *parameter, NSUInteger idx, BOOL *stop) {
			if ([description length] > 0) [description appendString:@", "];
			[description appendString:parameter.argumentName];
			[sorted addObject:parameter];
		}];
		GBLogWarn(@"%@: %ld unknown parameter descriptions (%@) found for method %@", comment.sourceInfo, [parameters count], description, method);
	}
	
	// Finaly re-register parameters to the comment.
	[comment replaceParametersWithParametersFromArray:sorted];
}

#pragma mark Properties

@synthesize commentsProcessor;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
