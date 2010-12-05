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

- (void)processSubclassForClass:(GBClassData *)class;
- (void)processDataProvider:(id<GBObjectDataProviding>)provider withComment:(GBComment *)comment;
- (void)processAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider;
- (void)processMethodsFromProvider:(GBMethodsProvider *)provider;

- (void)processComment:(GBComment *)comment;
- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method;
- (void)processHtmlReferencesForObject:(GBModelBase *)object;

- (void)removeUndocumentedObjectsFromStore;
- (void)removeUndocumentedObjectsInSet:(NSSet *)objects;

- (void)validateCommentForObject:(GBModelBase *)object;
- (BOOL)isCommentValid:(GBComment *)comment;
@property (retain) GBCommentsProcessor *commentsProcessor;
@property (retain) id<GBObjectDataProviding> currentContext;
@property (retain) id<GBApplicationSettingsProviding> settings;
@property (retain) id<GBStoreProviding> store;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
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
	GBLogVerbose(@"Processing parsed objects...");
	self.currentContext = nil;
	self.store = store;
	[self removeUndocumentedObjectsFromStore];
	[self processClasses];
	[self processCategories];
	[self processProtocols];
}

- (void)processClasses {
	// No need to process ivars as they are not used for output.
	for (GBClassData *class in self.store.classes) {
		GBLogInfo(@"Processing class %@...", class);
		[self validateCommentForObject:class];
		[self processSubclassForClass:class];
		[self processDataProvider:class withComment:class.comment];
		[self processHtmlReferencesForObject:class];
		GBLogDebug(@"Finished processing class %@.", class);
	}
}

- (void)processCategories {
	for (GBCategoryData *category in self.store.categories) {
		GBLogInfo(@"Processing category %@...", category);
		[self validateCommentForObject:category];
		[self processDataProvider:category withComment:category.comment];
		[self processHtmlReferencesForObject:category];
		GBLogDebug(@"Finished processing category %@.", category);
	}
}

- (void)processProtocols {
	for (GBProtocolData *protocol in self.store.protocols) {
		GBLogInfo(@"Processing protocol %@...", protocol);
		[self validateCommentForObject:protocol];
		[self processDataProvider:protocol withComment:protocol.comment];
		[self processHtmlReferencesForObject:protocol];
		GBLogDebug(@"Finished processing protocol %@.", protocol);
	}
}

#pragma mark Common data processing

- (void)processSubclassForClass:(GBClassData *)class {
	if ([class.nameOfSuperclass length] == 0) return;
	GBClassData *superclass = [self.store classWithName:class.nameOfSuperclass];
	if (superclass) {
		GBLogDebug(@"Setting superclass link of %@ to %@...", class, superclass);
		class.superclass = superclass;
	}
}

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
				GBLogDebug(@"Replacing %@ placeholder with known data from store...", registered);
				[provider replaceProtocol:adopted withProtocol:registered];
				break;
			}
		}
	}
}

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider {
	for (GBMethodData *method in provider.methods) {
		GBLogVerbose(@"Processing method %@...", method);
		[self validateCommentForObject:method];
		[self processComment:method.comment];
		[self processParametersFromComment:method.comment matchingMethod:method];
		[self processHtmlReferencesForObject:method];
		GBLogDebug(@"Finished processing method %@.", method);
	}
}

- (void)processHtmlReferencesForObject:(GBModelBase *)object {
	object.htmlReferenceName = [self.settings htmlReferenceNameForObject:object];
	object.htmlLocalReference = [self.settings htmlReferenceForObject:object fromSource:object];
}

#pragma mark Comments processing

- (void)processComment:(GBComment *)comment {
	if (![self isCommentValid:comment]) return;
	[self.commentsProcessor processComment:comment withContext:self.currentContext store:self.store];
}

- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method {
	// This is where we validate comment parameters and sort them in proper order.
	if (!comment || [comment.stringValue length] == 0) return;
	GBLogDebug(@"Validating processed parameters...");
	
	// Prepare names of all argument variables from the method and parameter descriptions from the comment. Note that we don't warn about issues here, we'll handle missing parameters while sorting and unkown parameters at the end.
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:[method.methodArguments count]];
	[method.methodArguments enumerateObjectsUsingBlock:^(GBMethodArgument *argument, NSUInteger idx, BOOL *stop) {
		if (!argument.argumentVar) return;
		[names addObject:argument.argumentVar];
		if (idx == [method.methodArguments count] - 1 && [argument isVariableArg]) [names addObject:@"..."];
	}];
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[comment.parameters count]];
	[comment.parameters enumerateObjectsUsingBlock:^(GBCommentArgument *parameter, NSUInteger idx, BOOL *stop) {
		[parameters setObject:parameter forKey:parameter.argumentName];
	}];
	
	// Sort the parameters in the same order as in the method. Warn if any parameter is not found. Also warn if there are more parameters in the comment than the method defines. Note that we still add these descriptions to the end of the sorted list!
	NSMutableArray *sorted = [NSMutableArray arrayWithCapacity:[parameters count]];
	[names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
		GBCommentArgument *parameter = [parameters objectForKey:name];
		if (!parameter) {
			GBLogWarn(@"%@: Description for parameter '%@' missing for %@!", comment.sourceInfo, name, method);
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
		GBLogWarn(@"%@: %ld unknown parameter descriptions (%@) found for %@", comment.sourceInfo, [parameters count], description, method);
	}
	
	// Finaly re-register parameters to the comment if necessary (no need if there's only one parameter).
	if ([names count] > 1) [comment replaceParametersWithParametersFromArray:sorted];
}

#pragma mark Helper methods

- (void)removeUndocumentedObjectsFromStore {
	[self removeUndocumentedObjectsInSet:self.store.classes];
	[self removeUndocumentedObjectsInSet:self.store.categories];
	[self removeUndocumentedObjectsInSet:self.store.protocols];
}

- (void)removeUndocumentedObjectsInSet:(NSSet *)objects {
	// Removes all undocumented objects and theri methods and properties as required by current settings. If settings don't allow removal, no object is removed. Note that we need to take care when deleting objects during enumerating: in both loops - top-level objects and members - we do a copy of returned array. Although for top-level objects this wouldn't be needed as the methods themselves return a copy, it's better to do additional shallow copy in case we change the functionality in the future to return cached values for example; this would break this code and present hard to find bug. Also note that we're assuming each object in the set is either a class, category or protocol...
	if (self.settings.keepUndocumentedObjects && self.settings.keepUndocumentedMembers) return;
	BOOL deleteObjects = !self.settings.keepUndocumentedObjects;
	BOOL deleteMethods = !self.settings.keepUndocumentedMembers;
	NSArray *array = [objects allObjects];
	for (GBModelBase *object in array) {
		// Get the methods from the provider.
		GBMethodsProvider *provider = [(id<GBObjectDataProviding>)object methods];
		NSArray *methods = [provider.methods copy];
			
		// Count or delete all undocumented methods.
		NSUInteger uncommentedMethodsCount = 0;
		for (GBMethodData *method in methods) {
			if ([self isCommentValid:method.comment]) continue;
			if (deleteMethods) {
				GBLogVerbose(@"Removing undocumented method %@...", method);
				[provider unregisterMethod:method];
			} else {
				uncommentedMethodsCount++;
			}
		}
	
		// Remove the object if it isn't commented or has only uncommented methods.
		NSUInteger commentedMethodsCount = [methods count] - uncommentedMethodsCount;
		if (deleteObjects && ![self isCommentValid:object.comment] && commentedMethodsCount == 0) {
			GBLogVerbose(@"Removing undocumented object %@...", object);
			[self.store unregisterTopLevelObject:object];
		}
	}
}

- (void)validateCommentForObject:(GBModelBase *)object {
	// Checks if the object is commented and warns if not.
	if (![self isCommentValid:object.comment]) {
		if ((object.isTopLevelObject && self.settings.warnOnUndocumentedObject) || self.settings.warnOnUndocumentedMember) {
			GBLogWarn(@"%@ is not documented!", object);
		}
	}
}

- (BOOL)isCommentValid:(GBComment *)comment {
	return (comment && [comment.stringValue length] > 0);
}

#pragma mark Properties

@synthesize commentsProcessor;
@synthesize currentContext;
@synthesize settings;
@synthesize store;

@end
