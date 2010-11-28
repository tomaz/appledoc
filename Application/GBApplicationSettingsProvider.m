//
//  GBApplicationSettingsProvider.m
//  appledoc
//
//  Created by Tomaz Kragelj on 3.10.10.
//  Copyright (C) 2010, Gentle Bytes. All rights reserved.
//

#import "GBDataObjects.h"
#import "GBApplicationSettingsProvider.h"

@interface GBApplicationSettingsProvider ()

- (BOOL)isTopLevelStoreObject:(id)object;
- (NSString *)outputPathForObject:(id)object withExtension:(NSString *)extension;
- (NSString *)relativePathPrefixFromObject:(GBModelBase *)source toObject:(GBModelBase *)destination;
- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object;
- (NSString *)htmlReferenceForTopLevelObject:(GBModelBase *)object fromTopLevelObject:(GBModelBase *)source;
- (NSString *)htmlReferenceForMember:(GBModelBase *)member prefixedWith:(NSString *)prefix;
- (NSString *)htmlExtension;

@end

#pragma mark -

@implementation GBApplicationSettingsProvider

#pragma mark Initialization & disposal

+ (id)provider {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	if (self) {
		self.outputPath = @"~/Downloads/examples/AppledocHtml";
		self.templatesPath = @"~/Dropbox/Xcode/Projects/Tools/appledoc/Project/Templates";
		self.ignoredPaths = [NSMutableSet set];
		self.commentComponents = [GBCommentComponentsProvider provider];
		self.stringTemplates = [GBApplicationStringsProvider provider];
	}
	return self;
}

#pragma mark HTML paths and references handling

- (NSString *)htmlOutputPath {
	return [self.outputPath stringByAppendingPathComponent:@"html"];
}

- (NSString *)htmlOutputPathForIndex {
	NSString *result = [self.htmlOutputPath stringByAppendingPathComponent:@"index"];
	return [result stringByAppendingPathExtension:[self htmlExtension]];
}

- (NSString *)htmlOutputPathForObject:(GBModelBase *)object {
	NSParameterAssert(object != nil);
	NSParameterAssert([self isTopLevelStoreObject:object]);
	NSString *inner = [self htmlReferenceForObjectFromIndex:object];
	return [self.htmlOutputPath stringByAppendingPathComponent:inner];
}

- (NSString *)htmlReferenceNameForObject:(GBModelBase *)object {
	NSParameterAssert(object != nil);
	if ([self isTopLevelStoreObject:object]) return [self htmlReferenceForObject:object fromSource:object];
	return [self htmlReferenceForMember:object prefixedWith:@""];
}

- (NSString *)htmlReferenceForObject:(GBModelBase *)object fromSource:(GBModelBase *)source {
	NSParameterAssert(object != nil);
	
	// Generate hrefs from index to objects:
	if (!source) {
		// To top-level object.
		if ([self isTopLevelStoreObject:object]) return [self htmlReferenceForObjectFromIndex:object];
		
		// To a member of top-level object.
		NSString *path = [self htmlReferenceForObjectFromIndex:object.parentObject];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// Generate hrefs from member to other objects:
	if (![self isTopLevelStoreObject:source]) {
		GBModelBase *sourceParent = source.parentObject;
		
		// To the parent or another top-level object.
		if ([self isTopLevelStoreObject:object]) return [self htmlReferenceForObject:object fromSource:sourceParent];

		// To same or another member of the same parent.
		if (object.parentObject == sourceParent) return [self htmlReferenceForMember:object prefixedWith:@"#"];

		// To a member of another top-level object.
		NSString *path = [self htmlReferenceForObject:object.parentObject fromSource:sourceParent];
		NSString *memberReference = [self htmlReferenceForMember:object prefixedWith:@"#"];
		return [NSString stringWithFormat:@"%@%@", path, memberReference];
	}
	
	// From top-level object to samo or another top level object.
	if (object == source || [self isTopLevelStoreObject:object]) {
		return [self htmlReferenceForTopLevelObject:object fromTopLevelObject:source];
	}
	
	// From top-level object to another top-level object member.
	NSString *memberPath = [self htmlReferenceForMember:object prefixedWith:@"#"];
	if (object.parentObject != source) {
		NSString *objectPath = [self htmlReferenceForTopLevelObject:object.parentObject fromTopLevelObject:source];
		return [NSString stringWithFormat:@"%@%@", objectPath, memberPath];
	}
	
	// From top-level object to one of it's members.
	return memberPath;
}

- (NSString *)htmlReferenceForObjectFromIndex:(GBModelBase *)object {
	return [self outputPathForObject:object withExtension:[self htmlExtension]];
}

- (NSString *)htmlReferenceForTopLevelObject:(GBModelBase *)object fromTopLevelObject:(GBModelBase *)source {
	NSString *path = [self outputPathForObject:object withExtension:[self htmlExtension]];
	if ([object isKindOfClass:[source class]]) return [path lastPathComponent];
	NSString *prefix = [self relativePathPrefixFromObject:source toObject:object];
	return [prefix stringByAppendingPathComponent:path];
}

- (NSString *)htmlReferenceForMember:(GBModelBase *)member prefixedWith:(NSString *)prefix {
	NSParameterAssert(member != nil);
	NSParameterAssert(prefix != nil);
	if ([member isKindOfClass:[GBMethodData class]]) {
		GBMethodData *method = (GBMethodData *)member;
		return [NSString stringWithFormat:@"%@//api/name/%@", prefix, method.methodSelector];
	}
	return @"";
}

- (NSString *)htmlExtension {
	return @"html";
}

#pragma mark Paths helper methods

- (NSString *)outputPathForObject:(id)object withExtension:(NSString *)extension {
	NSString *basePath = nil;
	NSString *name = nil;
	if ([object isKindOfClass:[GBClassData class]]) {
		basePath = @"Classes";
		name = [object nameOfClass];
	}
	else if ([object isKindOfClass:[GBCategoryData class]]) {
		basePath = @"Categories";
		name = [object idOfCategory];
	}
	else if ([object isKindOfClass:[GBProtocolData class]]) {		
		basePath = @"Protocols";
		name = [object nameOfProtocol];
	}
	
	if (basePath == nil || name == nil) return nil;
	basePath = [basePath stringByAppendingPathComponent:name];
	return [basePath stringByAppendingPathExtension:extension];
}

- (NSString *)relativePathPrefixFromObject:(GBModelBase *)source toObject:(GBModelBase *)destination {
	if ([source isKindOfClass:[destination class]]) return @"";
	return @"../";
}

#pragma mark Helper methods

- (BOOL)isTopLevelStoreObject:(id)object {
	if ([object isKindOfClass:[GBClassData class]] || [object isKindOfClass:[GBCategoryData class]] || [object isKindOfClass:[GBProtocolData class]])
		return YES;
	return NO;
}

#pragma mark Overriden methods

- (NSString *)description {
	return [self className];
}

#pragma mark Properties

@synthesize outputPath;
@synthesize templatesPath;
@synthesize ignoredPaths;
@synthesize commentComponents;
@synthesize stringTemplates;

@end
