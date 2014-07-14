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
- (void)processConstants;
- (void)processBlocks;
- (void)processDocuments;

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider;
- (void)processCommentForObject:(GBModelBase *)object;
- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method;
- (void)processHtmlReferencesForObject:(GBModelBase *)object;
- (void)copyKnownDocumentationForMethod:(GBMethodData *)method;

- (BOOL)removeUndocumentedObject:(id)object;
- (BOOL)removeUndocumentedMember:(GBMethodData *)object;

- (void)setupKnownObjectsFromStore;
- (void)mergeKnownCategoriesFromStore;
- (void)setupSuperclassForClass:(GBClassData *)class;
- (void)setupAdoptedProtocolsFromProvider:(GBAdoptedProtocolsProvider *)provider;

- (void)validateCommentsForObjectAndMembers:(GBModelBase *)object;
- (BOOL)isCommentValid:(GBComment *)comment;

@property (strong) GBCommentsProcessor *commentsProcessor;
@property (strong) id currentContext;
@property (strong) GBStore *store;
@property (strong) GBApplicationSettingsProvider *settings;

@end

#pragma mark -

@implementation GBProcessor

#pragma mark Initialization & disposal

+ (id)processorWithSettingsProvider:(id)settingsProvider {
	return [[self alloc] initWithSettingsProvider:settingsProvider];
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

- (void)processObjectsFromStore:(id)aStore {
	NSParameterAssert(aStore != nil);
	GBLogVerbose(@"Processing parsed objects...");
	self.currentContext = nil;
	self.store = aStore;
	[self setupKnownObjectsFromStore];
	[self mergeKnownCategoriesFromStore];
	[self processClasses];
	[self processCategories];
	[self processProtocols];
    [self processConstants];
    [self processBlocks];
	[self processDocuments];
}

- (void)processClasses {
	// No need to process ivars as they are not used for output. Note that we need to iterate over a copy of objects to prevent problems when removing undocumented ones!
	NSArray *classes = [self.store.classes allObjects];
	for (GBClassData *class in classes) {
		GBLogInfo(@"Processing class %@...", class);
		self.currentContext = class;
		[self processMethodsFromProvider:class.methods];
		if (![self removeUndocumentedObject:class]) {
			[self processCommentForObject:class];
			[self validateCommentsForObjectAndMembers:class];
			[self processHtmlReferencesForObject:class];
		}
		GBLogDebug(@"Finished processing class %@.", class);
	}
}

- (void)processCategories {
	NSArray *categories = [self.store.categories allObjects];
	for (GBCategoryData *category in categories) {
		GBLogInfo(@"Processing category %@...", category);
		self.currentContext = category;
		[self processMethodsFromProvider:category.methods];
		if (![self removeUndocumentedObject:category]) {
			[self processCommentForObject:category];
			[self validateCommentsForObjectAndMembers:category];
			[self processHtmlReferencesForObject:category];
		}
		GBLogDebug(@"Finished processing category %@.", category);
	}
}

- (void)processProtocols {
	NSArray *protocols = [self.store.protocols allObjects];
	for (GBProtocolData *protocol in protocols) {
		GBLogInfo(@"Processing protocol %@...", protocol);
		self.currentContext = protocol;
		[self processMethodsFromProvider:protocol.methods];
		if (![self removeUndocumentedObject:protocol]) {
			[self processCommentForObject:protocol];
			[self validateCommentsForObjectAndMembers:protocol];
			[self processHtmlReferencesForObject:protocol];
		}
		GBLogDebug(@"Finished processing protocol %@.", protocol);
	}
}

- (void)processConstants {
	NSArray *constants = [self.store.constants allObjects];
	for (GBTypedefEnumData *enumData in constants) {
		GBLogInfo(@"Processing constants %@...", enumData);
		self.currentContext = enumData;
		[self processConstantsFromProvider:enumData.constants];
		if (![self removeUndocumentedObject:enumData]) {
			[self processCommentForObject:enumData];
			[self validateCommentsForObjectAndMembers:enumData];
			[self processHtmlReferencesForObject:enumData];
		}
		GBLogDebug(@"Finished processing constant %@.", enumData);
	}
}

- (void)processBlocks {
    NSArray *blocks = [self.store.blocks allObjects];
    for (GBTypedefBlockData *blockData in blocks) {
        GBLogInfo(@"Processing blocks %@...", blockData);
        self.currentContext = blockData;
        if (![self removeUndocumentedObject:blockData]) {
            [self processCommentForObject:blockData];
            [self validateCommentsForObjectAndMembers:blockData];
            [self processHtmlReferencesForObject:blockData];
        }
        GBLogDebug(@"Finished processing blocks %@.", blockData);
    }
}

- (void)processDocuments {
	for (GBDocumentData *document in self.store.documents) {
		GBLogInfo(@"Processing static document %@...", document);
		self.currentContext = document;
		[self processCommentForObject:document];
		GBLogDebug(@"Finished processing document %@.", document);
	}
	for (GBDocumentData *document in self.store.customDocuments) {
		GBLogInfo(@"Processing custom document %@...", document);
		self.currentContext = document;
		[self processCommentForObject:document];
		GBLogDebug(@"Finished processing custom document %@.", document);
	}
}

#pragma mark Common data processing

- (void)processMethodsFromProvider:(GBMethodsProvider *)provider {
	NSArray *methods = [provider.methods copy];
	for (GBMethodData *method in methods) {
		GBLogVerbose(@"Processing method %@...", method);
		[self copyKnownDocumentationForMethod:method];
		if (![self removeUndocumentedMember:method]) {
			[self processCommentForObject:method];
			[self processParametersFromComment:method.comment matchingMethod:method];
			[self processHtmlReferencesForObject:method];
		}
		GBLogDebug(@"Finished processing method %@.", method);
	}
}

- (void)processBlocksForObject:(NSArray *)blocks {
    for (GBTypedefBlockData *block in blocks) {
        GBLogVerbose(@"Processing block %@...", block);
        [self processCommentForObject:block];
        GBLogDebug(@"Finished processing method %@.", block);
    }
}


- (void)processConstantsFromProvider:(GBEnumConstantProvider *)provider {
	NSArray *constants = [provider.constants copy];
	for (GBEnumConstantData *constant in constants) {
		GBLogVerbose(@"Processing constant %@...", constant);
		
        //if (![self removeUndocumentedMember:method]) {
        [self processCommentForObject:constant];
        [self processHtmlReferencesForObject:constant];
		//}
		GBLogDebug(@"Finished processing method %@.", constant);
	}
}

- (void)processHtmlReferencesForObject:(GBModelBase *)object {
	// Setups html reference name and local reference that's going to be used later on when generating HTML. This could easily be handled within the object accessors, but using a predefined value speeds up these frequently used values.
	object.htmlReferenceName = [self.settings htmlReferenceNameForObject:object];
	object.htmlLocalReference = [self.settings htmlReferenceForObject:object fromSource:object];
}

- (void)processCommentForObject:(GBModelBase *)object {
	// Processes the comment for the given object. If the comment is not valid, it's forced to nil to make simpler work for template engine later on. Note that comment is considered invalid if the object isn't commented or has comment, but it's string value is nil or empty string.
	if (![self isCommentValid:object.comment]) {
		object.comment = nil;
		return;
	}
	
	// Let comments processor parse comment string value into object representation.
	self.commentsProcessor.alwaysRepeatFirstParagraph = (object.isTopLevelObject || object.isStaticDocument) && ![object isKindOfClass: [GBTypedefBlockData class]];
	[self.commentsProcessor processCommentForObject:object withContext:self.currentContext store:self.store];
}

- (void)processParametersFromComment:(GBComment *)comment matchingMethod:(GBMethodData *)method {
	// This is where we validate comment parameters and sort them in proper order.
	if (!comment || [comment.stringValue length] == 0 || comment.isCopied) return;
	GBLogDebug(@"Validating processed parameters...");
	
	// Prepare names of all argument variables from the method and parameter descriptions from the comment. Note that we don't warn about issues here, we'll handle missing parameters while sorting and unkown parameters at the end.
	NSMutableArray *names = [NSMutableArray arrayWithCapacity:[method.methodArguments count]];
	[method.methodArguments enumerateObjectsUsingBlock:^(GBMethodArgument *argument, NSUInteger idx, BOOL *stop) {
		if (!argument.argumentVar) return;
		[names addObject:argument.argumentVar];
		if (idx == [method.methodArguments count] - 1 && [argument isVariableArg]) [names addObject:@"..."];
	}];
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[comment.methodParameters count]];
	[comment.methodParameters enumerateObjectsUsingBlock:^(GBCommentArgument *parameter, NSUInteger idx, BOOL *stop) {
		[parameters setObject:parameter forKey:parameter.argumentName];
	}];
	
	// Sort the parameters in the same order as in the method. Warn if any parameter is not found. Also warn if there are more parameters in the comment than the method defines. Note that we still add these descriptions to the end of the sorted list!
	NSMutableArray *sorted = [NSMutableArray arrayWithCapacity:[parameters count]];
	[names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
		GBCommentArgument *parameter = [parameters objectForKey:name];
		if (!parameter) {
            if (self.settings.warnOnMissingMethodArgument && method.includeInOutput)
                GBLogXWarn(comment.sourceInfo, @"%@: Description for parameter '%@' missing for %@!", comment.sourceInfo, name, method);
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
		if (method.includeInOutput) GBLogXWarn(comment.sourceInfo, @"%@: %ld unknown parameter descriptions (%@) found for %@", comment.sourceInfo, [parameters count], description, method);
	}
	
	// Finaly re-register parameters to the comment if necessary (no need if there's only one parameter).
	if ([names count] > 1) {
		[comment.methodParameters removeAllObjects];
		[comment.methodParameters addObjectsFromArray:sorted];
	}
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
				superMethod.comment.originalContext = superMethod.parentObject;
				method.comment = superMethod.comment;
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
			if (protocolMethod.methodSection.sectionName && !method.methodSection.sectionName) {
				GBLogDebug(@"Copying section name %@ from %@...", protocolMethod.methodSection.sectionName, protocol);
				method.methodSection.sectionName = protocolMethod.methodSection.sectionName;
			}
			protocolMethod.comment.originalContext = protocolMethod.parentObject;
			method.comment = protocolMethod.comment;
			return;
		}
	}
}

- (BOOL)removeUndocumentedObject:(id)object {
	// Removes the given top level object if it's not commented and all of it's methods are uncommented. Returns YES if the object was removed, NO otherwise.
	if (self.settings.keepUndocumentedObjects) return NO;
	if ([self isCommentValid:[(GBModelBase *)object comment]]) return NO;
	
	// Only remove if all methods are uncommented. Note that this also removes methods regardless of keepUndocumentedMembers setting, however if the object itself is commented, we'll keep methods.
	if([object conformsToProtocol:@protocol(GBObjectDataProviding)])
    {
        BOOL hasCommentedMethods = NO;
        
        GBMethodsProvider *provider = [(id<GBObjectDataProviding>)object methods];
        for (GBMethodData *method in provider.methods) {
            if ([self isCommentValid:method.comment]) {
                hasCommentedMethods = YES;
                break;
            }
        }
        
        // Remove the object if it only has uncommented methods.
        if (!hasCommentedMethods) {
            GBLogVerbose(@"Removing undocumented object %@...", object);
            [self.store unregisterTopLevelObject:object];
            return YES;
        }
	}
	
	return NO;
}

- (BOOL)removeUndocumentedMember:(GBMethodData *)object {
	// Removes the given method if it's not commented and returns YES if removed, NO otherwise.
	if (self.settings.keepUndocumentedMembers) return NO;
	if ([self isCommentValid:object.comment]) return NO;

	// Remove the method and all empty sections to cleanup the object for output generation.
	GBLogVerbose(@"Removing undocumented method %@...", object);
	GBMethodsProvider *provider = [(id<GBObjectDataProviding>)object.parentObject methods];
	[provider unregisterMethod:object];
	[provider unregisterEmptySections];	
	return YES;
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
        GBMethodsProvider *classMethodProvider = class.methods;
        classMethodProvider.useAlphabeticalOrder = !self.settings.useCodeOrder;
        if ([category.methods.methods count] > 0) {
			// If we should merge all section into a single section per category, create it now. Note that name is different whether this is category or extension.
			if (!self.settings.keepMergedCategoriesSections) {
				GBLogDebug(@"Creating single section for methods merged from %@...", category);
				NSString *key = category.isExtension ? @"mergedExtensionSectionTitle" :  @"mergedCategorySectionTitle";
				NSString *template = [self.settings.stringTemplates.objectPage objectForKey:key];
				NSString *name = category.isExtension ? template : [NSString stringWithFormat:template, category.nameOfCategory];
				[classMethodProvider registerSectionWithName:name];
			}
			
			// Merge all sections and all the methods, optionally create a separate section for each section from category.
			for (GBMethodSectionData *section in category.methods.sections) {
				GBLogDebug(@"Merging section %@ from %@...", section, category);
				if (self.settings.keepMergedCategoriesSections) {
					if (self.settings.prefixMergedCategoriesSectionsWithCategoryName && !category.isExtension) {
						NSString *template = [self.settings.stringTemplates.objectPage objectForKey:@"mergedPrefixedCategorySectionTitle"];
						NSString *name = [NSString stringWithFormat:template, category.nameOfCategory, section.sectionName];
						[classMethodProvider registerSectionWithName:name];
					} else {
						[classMethodProvider registerSectionWithName:section.sectionName];
					}
				}
				
				for (GBMethodData *method in section.methods) {
					GBLogDebug(@"Merging method %@ from %@...", method, category);
					[classMethodProvider registerMethod:method];
				}
			}
		}
		
		// Append category comment to class.
		if (self.settings.mergeCategoryCommentToClass && [category.comment.stringValue length] > 0) {
			GBLogDebug(@"Merging category %@ comment to class...", category);
			if ([class.comment.stringValue length] > 0) {
				class.comment.stringValue = [NSString stringWithFormat:@"%@\n%@", class.comment.stringValue, category.comment.stringValue];
			} else {
				class.comment = category.comment;
			}
		}
		
		// Finally clean all empty sections and remove merged category from the store.
		[classMethodProvider unregisterEmptySections];
		[self.store unregisterTopLevelObject:category];
	}
}
													
#pragma mark Helper methods

- (void)validateCommentsForObjectAndMembers:(GBModelBase *)object {
    if (!object.includeInOutput) return;
    
	// Checks if the object is commented and warns if not. This validates given object and all it's members comments! The reason for doing it together is due to the fact that we first process all members and then handle the object. At that point we can even remove the object if not documented. So we can't validate members before as we don't know whether they will be deleted together with their parent object too...
    if (![self isCommentValid:object.comment] && self.settings.warnOnUndocumentedObject) {
        GBLogXWarn(object.prefferedSourceInfo, @"%@ is not documented!", object);
    }
	
	// Handle methods.
    if([object conformsToProtocol:@protocol(GBObjectDataProviding)])
    {
        for (GBMethodData *method in [[(id<GBObjectDataProviding>)object methods] methods]) {
            if (![self isCommentValid:method.comment] && self.settings.warnOnUndocumentedMember) {
                GBLogXWarn(method.prefferedSourceInfo, @"%@ is not documented!", method);
            }
        }
        
    }
    
    if([object isKindOfClass:[GBTypedefEnumData class]])
    {
        for(GBEnumConstantData *constant in ((GBTypedefEnumData *)object).constants.constants)
        {
            if (![self isCommentValid:constant.comment] && self.settings.warnOnUndocumentedMember) {
                GBLogXWarn(constant.prefferedSourceInfo, @"%@ is not documented!", constant);
            }
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
