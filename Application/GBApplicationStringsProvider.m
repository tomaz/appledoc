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
	return [[[self alloc] init] autorelease];
}

#pragma mark Object output strings

- (NSDictionary *)objectPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"%@ Class Reference" forKey:@"classTitle"];
		[result setObject:@"%1$@(%2$@) Category Reference" forKey:@"categoryTitle"];
		[result setObject:@"%@ Protocol Reference" forKey:@"protocolTitle"];
		[result setObject:@"%@ Methods" forKey:@"mergedCategorySectionTitle"];
		[result setObject:@"Extension Methods" forKey:@"mergedExtensionSectionTitle"];
		[result setObject:@"%2$@ from %1$@" forKey:@"mergedPrefixedCategorySectionTitle"];
	}
	return result;
}

- (NSDictionary *)objectSpecifications {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"Inherits from" forKey:@"inheritsFrom"];
		[result setObject:@"Conforms to" forKey:@"conformsTo"];
		[result setObject:@"Declared in" forKey:@"declaredIn"];
		[result setObject:@"Companion guide" forKey:@"companionGuide"];
	}
	return result;
}

- (NSDictionary *)objectOverview {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"Overview" forKey:@"title"];
	}
	return result;
}

- (NSDictionary *)objectTasks {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"Tasks" forKey:@"title"];
		[result setObject:@"Other Methods" forKey:@"otherMethodsSectionName"];
		[result setObject:@"required method" forKey:@"requiredMethod"];
		[result setObject:@"property" forKey:@"property"];
	}
	return result;
}

- (NSDictionary *)objectMethods {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"Class Methods" forKey:@"classMethodsTitle"];
		[result setObject:@"Instance Methods" forKey:@"instanceMethodsTitle"];
		[result setObject:@"Properties" forKey:@"propertiesTitle"];
		[result setObject:@"Parameters" forKey:@"parametersTitle"];
		[result setObject:@"Return Value" forKey:@"resultTitle"];
		[result setObject:@"Availability" forKey:@"availability"];
		[result setObject:@"Discussion" forKey:@"discussionTitle"];
		[result setObject:@"Exceptions" forKey:@"exceptionsTitle"];
		[result setObject:@"See Also" forKey:@"seeAlsoTitle"];
		[result setObject:@"Declared In" forKey:@"declaredInTitle"];
	}
	return result;
}

#pragma mark Document output strings

- (NSDictionary *)documentPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"%@ Document" forKey:@"titleTemplate"];
	}
	return result;
}

#pragma mark Index output strings

- (NSDictionary *)indexPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"%@ Reference" forKey:@"titleTemplate"];
		[result setObject:@"Class References" forKey:@"classesTitle"];
		[result setObject:@"Category References" forKey:@"categoriesTitle"];
		[result setObject:@"Protocol References" forKey:@"protocolsTitle"];
	}
	return result;
}

- (NSDictionary *)hierarchyPage {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"%@ Hierarchy" forKey:@"titleTemplate"];
		[result setObject:@"Class Hierarchy" forKey:@"classesTitle"];
		[result setObject:@"Category References" forKey:@"categoriesTitle"];
		[result setObject:@"Protocol References" forKey:@"protocolsTitle"];
	}
	return result;
}

#pragma mark Documentation set output strings

- (NSDictionary *)docset {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"Classes" forKey:@"classesTitle"];
		[result setObject:@"Categories" forKey:@"categoriesTitle"];
		[result setObject:@"Protocols" forKey:@"protocolsTitle"];
	}
	return result;
}

- (NSDictionary *)appledocData {
	static NSMutableDictionary *result = nil;
	if (!result) {
		result = [[NSMutableDictionary alloc] init];
		[result setObject:@"appledoc" forKey:@"tool"];
		[result setObject:@"2.0.4" forKey:@"version"];
		[result setObject:@"703" forKey:@"build"];
		[result setObject:@"http://appledoc.gentlebytes.com" forKey:@"homepage"];
	}
	return result;
}

@end
