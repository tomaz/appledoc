//
//  GBApplicationStringsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 1.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBApplicationStringsProvider.h"

@implementation GBApplicationStringsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[self alloc] init];
}

#pragma mark Object output strings

- (NSDictionary *)objectPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"classTitle"] = NSLocalizedString(@"%@ Class Reference", @"%@ Class Reference");
		result[@"categoryTitle"] = NSLocalizedString(@"%1$@(%2$@) Category Reference", @"%1$@(%2$@) Category Reference");
		result[@"protocolTitle"] = NSLocalizedString(@"%@ Protocol Reference", @"%@ Protocol Reference");
		result[@"constantTitle"] = NSLocalizedString(@"%@ Constants Reference", @"%@ Constants Reference");
        result[@"blockTitle"] = NSLocalizedString(@"%@ Block Reference", @"%@ Block Reference");
		result[@"mergedCategorySectionTitle"] = NSLocalizedString(@"%@ Methods", @"%@ Methods");
		result[@"mergedExtensionSectionTitle"] = NSLocalizedString(@"Extension Methods", @"Extension Methods");
		result[@"mergedPrefixedCategorySectionTitle"] = NSLocalizedString(@"%2$@ from %1$@", @"%2$@ from %1$@");
	}
	return result;
}

- (NSDictionary *)objectSpecifications {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"inheritsFrom"] = NSLocalizedString(@"Inherits from", @"Inherits from");
		result[@"conformsTo"] = NSLocalizedString(@"Conforms to", @"Conforms to");
        result[@"references"] = NSLocalizedString(@"References", @"References");
        result[@"availability"] = NSLocalizedString(@"Availability", @"Availability");
		result[@"declaredIn"] = NSLocalizedString(@"Declared in", @"Declared in");
		result[@"companionGuide"] = NSLocalizedString(@"Companion guide", @"Companion guide");
	}
	return result;
}

- (NSDictionary *)objectOverview {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"title"] = NSLocalizedString(@"Overview", @"Overview");
	}
	return result;
}

- (NSDictionary *)objectTasks {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"title"] = NSLocalizedString(@"Tasks", @"Tasks");
		result[@"otherMethodsSectionName"] = NSLocalizedString(@"Other Methods", @"Other Methods");
		result[@"requiredMethod"] = NSLocalizedString(@"required method", @"required method");
		result[@"property"] = NSLocalizedString(@"property", @"property");
	}
	return result;
}

- (NSDictionary *)objectMethods {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"classMethodsTitle"] = NSLocalizedString(@"Class Methods", @"Class Methods");
		result[@"instanceMethodsTitle"] = NSLocalizedString(@"Instance Methods", @"Instance Methods");
        result[@"blockDefTitle"] = NSLocalizedString(@"Block Definition", @"Block Definition");
		result[@"propertiesTitle"] = NSLocalizedString(@"Properties", @"Properties");
		result[@"parametersTitle"] = NSLocalizedString(@"Parameters", @"Parameters");
		result[@"resultTitle"] = NSLocalizedString(@"Return Value", @"Return Value");
		result[@"availability"] = NSLocalizedString(@"Availability", @"Availability");
		result[@"discussionTitle"] = NSLocalizedString(@"Discussion", @"Discussion");
		result[@"exceptionsTitle"] = NSLocalizedString(@"Exceptions", @"Exceptions");
		result[@"seeAlsoTitle"] = NSLocalizedString(@"See Also", @"See Also");
		result[@"declaredInTitle"] = NSLocalizedString(@"Declared In", @"Declared In");
	}
	return result;
}

#pragma mark Document output strings

- (NSDictionary *)documentPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = NSLocalizedString(@"%@ Document", @"%@ Document");
	}
	return result;
}

#pragma mark Index output strings

- (NSDictionary *)indexPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = NSLocalizedString(@"%@ Reference", @"%@ Reference");
		result[@"docsTitle"] = NSLocalizedString(@"Programming Guides", @"Programming Guides");
		result[@"classesTitle"] = NSLocalizedString(@"Class References", @"Class References");
		result[@"categoriesTitle"] = NSLocalizedString(@"Category References", @"Category References");
		result[@"protocolsTitle"] = NSLocalizedString(@"Protocol References", @"Protocol References");
        result[@"constantsTitle"] = NSLocalizedString(@"Constant References", @"Constant References");
        result[@"blocksTitle"] = NSLocalizedString(@"Block References", @"Block References");
	}
	return result;
}

- (NSDictionary *)hierarchyPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = NSLocalizedString(@"%@ Hierarchy", @"%@ Hierarchy");
		result[@"classesTitle"] = NSLocalizedString(@"Class Hierarchy", @"Class Hierarchy");
		result[@"categoriesTitle"] = NSLocalizedString(@"Category References", @"Category References");
		result[@"protocolsTitle"] = NSLocalizedString(@"Protocol References", @"Protocol References");
        result[@"constantsTitle"] = NSLocalizedString(@"Constant References", @"Constant References");
        result[@"blocksTitle"] = NSLocalizedString(@"Block References", @"Block References");
	}
	return result;
}

#pragma mark Documentation set output strings

- (NSDictionary *)docset {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"docsTitle"] = NSLocalizedString(@"Programming Guides", @"Programming Guides");
		result[@"classesTitle"] = NSLocalizedString(@"Classes", @"Classes");
		result[@"categoriesTitle"] = NSLocalizedString(@"Categories", @"Categories");
		result[@"protocolsTitle"] = NSLocalizedString(@"Protocols", @"Protocols");
        result[@"constantsTitle"] = NSLocalizedString(@"Constants", @"Constants");
        result[@"blocksTitle"] = NSLocalizedString(@"Blocks", @"Blocks");
	}
	return result;
}

- (NSDictionary *)appledocData {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"tool"] = @"appledoc";
		result[@"version"] = @"2.2.1";
		result[@"build"] = @"1334";
		result[@"homepage"] = @"http://appledoc.gentlebytes.com";
	}
	return result;
}

@end
