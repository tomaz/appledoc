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
		result[@"classTitle"] = @"%@ Class Reference";
		result[@"categoryTitle"] = @"%1$@(%2$@) Category Reference";
		result[@"protocolTitle"] = @"%@ Protocol Reference";
		result[@"constantTitle"] = @"%@ Constants Reference";
        result[@"blockTitle"] = @"%@ Block Reference";
		result[@"mergedCategorySectionTitle"] = @"%@ Methods";
		result[@"mergedExtensionSectionTitle"] = @"Extension Methods";
		result[@"mergedPrefixedCategorySectionTitle"] = @"%2$@ from %1$@";
	}
	return result;
}

- (NSDictionary *)objectSpecifications {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"inheritsFrom"] = @"Inherits from";
		result[@"conformsTo"] = @"Conforms to";
        result[@"references"] = @"References";
        result[@"availability"] = @"Availability";
		result[@"declaredIn"] = @"Declared in";
		result[@"companionGuide"] = @"Companion guide";
	}
	return result;
}

- (NSDictionary *)objectOverview {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"title"] = @"Overview";
	}
	return result;
}

- (NSDictionary *)objectTasks {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"title"] = @"Tasks";
		result[@"otherMethodsSectionName"] = @"Other Methods";
		result[@"requiredMethod"] = @"required method";
		result[@"property"] = @"property";
	}
	return result;
}

- (NSDictionary *)objectMethods {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"classMethodsTitle"] = @"Class Methods";
		result[@"instanceMethodsTitle"] = @"Instance Methods";
        result[@"blockDefTitle"] = @"Block Definition";
		result[@"propertiesTitle"] = @"Properties";
		result[@"parametersTitle"] = @"Parameters";
		result[@"resultTitle"] = @"Return Value";
		result[@"availability"] = @"Availability";
		result[@"discussionTitle"] = @"Discussion";
		result[@"exceptionsTitle"] = @"Exceptions";
		result[@"seeAlsoTitle"] = @"See Also";
		result[@"declaredInTitle"] = @"Declared In";
	}
	return result;
}

#pragma mark Document output strings

- (NSDictionary *)documentPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = @"%@ Document";
	}
	return result;
}

#pragma mark Index output strings

- (NSDictionary *)indexPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = @"%@ Reference";
		result[@"docsTitle"] = @"Programming Guides";
		result[@"classesTitle"] = @"Class References";
		result[@"categoriesTitle"] = @"Category References";
		result[@"protocolsTitle"] = @"Protocol References";
        result[@"constantsTitle"] = @"Constant References";
        result[@"blocksTitle"] = @"Block References";
	}
	return result;
}

- (NSDictionary *)hierarchyPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"titleTemplate"] = @"%@ Hierarchy";
		result[@"classesTitle"] = @"Class Hierarchy";
		result[@"categoriesTitle"] = @"Category References";
		result[@"protocolsTitle"] = @"Protocol References";
        result[@"constantsTitle"] = @"Constant References";
        result[@"blocksTitle"] = @"Block References";
	}
	return result;
}

#pragma mark Documentation set output strings

- (NSDictionary *)docset {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		result[@"docsTitle"] = @"Programming Guides";
		result[@"classesTitle"] = @"Classes";
		result[@"categoriesTitle"] = @"Categories";
		result[@"protocolsTitle"] = @"Protocols";
        result[@"constantsTitle"] = @"Constants";
        result[@"blocksTitle"] = @"Blocks";
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
