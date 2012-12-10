//
//  CategoryInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectLinkInfo.h"
#import "CategoryInfo.h"

@implementation CategoryInfo

- (NSString *)nameOfClass {
	if (!_categoryClass) return nil;
	return self.categoryClass.nameOfObject;
}

- (ObjectLinkInfo *)categoryClass {
	if (_categoryClass) return _categoryClass;
	LogDebug(@"Initializing %@ class link due to first access...");
	_categoryClass = [[ObjectLinkInfo alloc] init];
	return _categoryClass;
}

#pragma mark - Category identification

- (NSString *)uniqueObjectID {
	return [NSString stringWithFormat:@"%@(%@)", self.nameOfClass, self.isCategory ? self.nameOfCategory : @""];
}

- (NSString *)objectCrossRefPathTemplate {
	NSString *descriptor = self.isExtension ? self.nameOfClass : self.uniqueObjectID;
	return [NSString stringWithFormat:@"$CATEGORIES/%@.$EXT", descriptor];
}

#pragma mark - Properties

- (BOOL)isCategory {
	return (self.nameOfCategory.length > 0);
}

- (BOOL)isExtension {
	return !self.isCategory;
}

@end

#pragma mark - 

@implementation CategoryInfo (Logging)

- (NSString *)description {
	if (!self.nameOfClass) return @"category";
	return [NSString gb_format:@"@interface %@ w/ %@", [self uniqueObjectID], [super description]];
}

- (NSString *)debugDescription {
	NSMutableString *result = [self descriptionStringWithComment];
	[result appendFormat:@"@interface %@ (", self.nameOfClass];
	if (self.isCategory) [result appendString:self.nameOfCategory];
	[result appendString:@")"];
	[result appendString:[super debugDescription]];
	return result;
}

@end
