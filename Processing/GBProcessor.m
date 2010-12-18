//
//  GBProcessor.m
//  appledoc
//
//  Created by Tomaz Kragelj on 27.8.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBCommentsProcessor.h"
#import "GBProcessor.h"

@interface GBProcessor ()

- (void)processClasses;
- (void)processCategories;
- (void)processProtocols;
- (void)processMethodsFromProvider:(GBMethodsProvider *)provider;
- (void)processComment:(GBComment *)comment;
- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method;
- (void)processHtmlReferencesForObject:(GBModelBase *)object;
- (void)copyKnownDocumentationForMethod:(GBMethodData *)method;
- (BOOL)removeUndocumentedMembersAndObject:(id)object;

- (void)setupKnownObjectsFromStore;
- (void)mergeKnownCategoriesFromStore;
- (void)setupSuperclassForClass:(GBClassData *)class;
- (void)setupAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider;

- (void)validateCommentForObject:(GBModelBase *)object;
- (BOOL)isCommentValid:(GBComment *)comment;

@property (retain) GBCommentsProcessor *commentsProcessor;
@property (retain) id<GBObjectDataProviding> currentContext;
@property (retain) GBStore *store;
@property (retain) GBApplicationSettingsProvider *settings;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[[self alloc] initWithSettingsProvider:settingsProvider] autorelease];
}

- (id)initWithSettingsProvider:(id)settingsProvider {
	NSParameterAssert(settingsProvider != nil);
	GBLogDebug(@"Initializing processor with settings provider %@...", settingsProvider);
	self = [super init];
	if (self) {
		self.settings = settingsProvider;
		self.commentsProcessor = [GBCommentsProcessor processorWithSettingsProvider:self.settings];
	}
	return self;
}

#pragma mark Processing handling

- (void)processObjectsFromStore:(id)store {
	NSParameterAssert(store != nil);
	GBLogVerbose(@"Processing parsed objects...");
	self.currentContext = nil;
	self.store = store;
	[self setupKnownObjectsFromStore];
	[self mergeKnownCategoriesFromStore];
	[self processClasses];
	[self processCategories];
	[self processProtocols];
}

- (void)processClasses {
	// No need to process ivars as they are not used for output. Note that we need to iterate over a copy of objects to prevent problems when removing undocumented ones!
	NSArray *classes = [self.store.classes allObjects];
	for (GBClassData *class in classes) {
		GBLogInfo(@"Processing class %@...", class);
		self.currentContext = class;
		[self validateCommentForObject:class];
		[self processComment:class.comment];
		[self processMethodsFromProvider:class.methods];
		[self removeUndocumentedMembersAndObject:class];
		[self processHtmlReferencesForObject:class];
		GBLogDebug(@"Finished processing class %@.", class);
	}
}

- (void)processCategories {
	NSArray *categories = [self.store.categories allObjects];
	for (GBCategoryData *category in categories) {
		GBLogInfo(@"Processing category %@...", category);
		self.currentContext = category;
		[self validateCommentForObject:category];
		[self processComment:category.comment];
		[self processMethodsFromProvider:category.methods];
		[self removeUndocumentedMembersAndObject:category];
		[self processHtmlReferencesForObject:category];
		GBLogDebug(@"Finished processing category %@.", category);
	}
}

- (void)processProtocols {
	NSArray *protocols = [self.store.protocols allObjects];
	for (GBProtocolData *protocol in protocols) {
		GBLogInfo(@"Processing protocol %@...", protocol);
		self.currentContext = protocol;
		[self validateCommentForObject:protocol];
		[self processComment:protocol.comment];
		[self processMethodsFromProvider:protocol.methods];
		[self removeUndocumentedMembersAndObject:protocol];
		[self processHtmlReferencesForObject:protocol];
		GBLogDebug(@"Finished processing protocol %@.", protocol);
	}
}

#pragma mark Common data processing

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider {
	for (GBMethodData *method in provider.methods) {
		GBLogVerbose(@"Processing method %@...", method);
		[self copyKnownDocumentationForMethod:method];
		[self validateCommentForObject:method];
		[self processComment:method.comment];
		[self processParametersFromComment:method.comment matchingMethod:method];
		[self processHtmlReferencesForObject:method];
		GBLogDebug(@"Finished processing method %@.", method);
	}
}

- (void)processHtmlReferencesForObject:(GBModelBase *)object {
	// Setups html reference name and local reference that's going to be used later on when generating HTML. This could easily be handled within the object accessors, but using a predefined value speeds up these frequently used values.
	object.htmlReferenceName = [self.settings htmlReferenceNameForObject:object];
	object.htmlLocalReference = [self.settings htmlReferenceForObject:object fromSource:object];
}

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

- (void)copyKnownDocumentationForMethod:(GBMethodData *)method {
	// Copies method documentation from known superclasses or adopted protocols.
	if (!self.settings.findUndocumentedMembersDocumentation || [self isCommentValid:method.comment]) return;
	
	// First search within superclass hierarchy. This only works for classes.
	if ([method.parentObject isKindOfClass:[GBClassData class]]) {
		GBClassData *class = [(GBClassData *)method.parentObject superclass];
		while (class) {
			GBMethodData *superMethod = [class.methods methodBySelector:method.methodSelector];
			if (superMethod.comment) {
				GBLogVerbose(@"Copying documentation for %@ from superclass %@...", method, class);
				GBComment *comment = [GBComment commentWithStringValue:superMethod.comment.stringValue];
				method.comment = comment;
				return;
			}
			class = class.superclass;
		}
	}
	
	// If not found on superclass, search within adopted protocols.
	GBAdoptedProtocolsProvider *protocols = [method.parentObject adoptedProtocols];
	for (GBProtocolData *protocol in protocols.protocols) {
		GBMethodData *protocolMethod = [protocol.methods methodBySelector:method.methodSelector];
		if (protocolMethod.comment) {
			GBLogVerbose(@"Copying documentation for %@ from adopted protocol %@...", method, protocol);
			GBComment *comment = [GBComment commentWithStringValue:protocolMethod.comment.stringValue];
			method.comment = comment;
			return;
		}
	}
}

- (BOOL)removeUndocumentedMembersAndObject:(id)object {
	// Removes all undocumented members from the given top-level object as well as the object itself! The result is YES if we deleted the object, NO otherwise. Note that we need to use copies of lists to prevent the actual lists being changed while we're iterating over them!
	GBMethodsProvider *provider = [(id<GBObjectDataProviding>)object methods];
	NSArray *methods = [provider.methods copy];
	
	// Count and delete all undocumented methods.
	NSUInteger uncommentedMethodsCount = 0;
	for (GBMethodData *method in methods) {
		if ([self isCommentValid:method.comment]) continue;
		if (!self.settings.keepUndocumentedMembers) {
			GBLogVerbose(@"Removing undocumented method %@...", method);
			[provider unregisterMethod:method];
		}
		uncommentedMethodsCount++;
	}
	
	// Remove the object if it isn't commented or has only uncommented methods.
	NSUInteger commentedMethodsCount = [methods count] - uncommentedMethodsCount;
	GBComment *comment = [(GBModelBase *)object comment];
	if (!self.settings.keepUndocumentedObjects && ![self isCommentValid:comment] && commentedMethodsCount == 0) {
		GBLogVerbose(@"Removing undocumented object %@...", object);
		[self.store unregisterTopLevelObject:object];
		return YES;
	}
	
	return NO;
}

#pragma mark Known objects handling

- (void)setupKnownObjectsFromStore {
	// Setups links to superclasses and adopted protocols. This should be sent first so that the data is prepared for later processing.
	GBLogInfo(@"Checking for known superclasses and adopted protocols...");
	for (GBClassData *class in self.store.classes) {
		[self setupSuperclassForClass:class];
		[self setupAdoptedProtocolsFromProvider:class.adoptedProtocols];
	}
	for (GBCategoryData *category in self.store.categories) {
		[self setupAdoptedProtocolsFromProvider:category.adoptedProtocols];
	}
	for (GBProtocolData *protocol in self.store.protocols) {
		[self setupAdoptedProtocolsFromProvider:protocol.adoptedProtocols];
	}
}

- (void)setupSuperclassForClass:(GBClassData *)class {
	// This setups super class links for known superclasses.
	if ([class.nameOfSuperclass length] == 0) return;
	GBClassData *superclass = [self.store classWithName:class.nameOfSuperclass];
	if (superclass) {
		GBLogDebug(@"Setting superclass link of %@ to %@...", class, superclass);
		class.superclass = superclass;
	}
}

- (void)setupAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider {
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

- (void)mergeKnownCategoriesFromStore {
	GBLogInfo(@"Merging known categories to classes...");
	if (!self.settings.mergeCategoriesToClasses) return;
	NSSet *categories = [self.store.categories copy];
	for (GBCategoryData *category in categories) {
		GBLogVerbose(@"Checking %@ for merging...", category);
		
		// Get the class and continue with next category if unknown class is extended.
		GBClassData *class = [self.store classWithName:category.nameOfClass];
		if (!class) {
			GBLogDebug(@"Category %@ extends unknown class %@, skipping merging.", category, category.nameOfClass);
			continue;
		}
		
		// Merge all methods from category to the class. We can leave methods within the category as we'll delete it later on anyway.
		if ([category.methods.methods count] > 0) {
			// If we should merge all section into a single section per category, create it now. Note that name is different whether this is category or extension.
			if (!self.settings.keepMergedCategoriesSections) {
				GBLogDebug(@"Creating single section for methods merged from %@...", category);
				NSString *key = category.isExtension ? @"mergedExtensionSectionTitle" :  @"mergedCategorySectionTitle";
				NSString *template = [self.settings.stringTemplates.objectPage objectForKey:key];
				NSString *name = category.isExtension ? template : [NSString stringWithFormat:template, category.nameOfCategory];
				[class.methods registerSectionWithName:name];
			}
			
			// Merge all sections and all the methods, optionally create a separate section for each section from category.
			for (GBMethodSectionData *section in category.methods.sections) {
				GBLogDebug(@"Merging section %@ from %@...", section, category);
				if (self.settings.keepMergedCategoriesSections) {
					if (self.settings.prefixMergedCategoriesSectionsWithCategoryName && !category.isExtension) {
						NSString *template = [self.settings.stringTemplates.objectPage objectForKey:@"mergedPrefixedCategorySectionTitle"];
						NSString *name = [NSString stringWithFormat:template, category.nameOfCategory, section.sectionName];
						[class.methods registerSectionWithName:name];
					} else {
						[class.methods registerSectionWithName:section.sectionName];
					}
				}
				
				for (GBMethodData *method in section.methods) {
					GBLogDebug(@"Merging method %@ from %@...", method, category);
					[class.methods registerMethod:method];
				}
			}
		}
		
		// Finally remove merged category from the store.
		[self.store unregisterTopLevelObject:category];
	}
}
													
#pragma mark Helper methods

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
