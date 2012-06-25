//
//  CategoryInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "CategoryInfo.h"

@implementation CategoryInfo

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
	NSMutableString *result = [NSMutableString string];
	[result appendFormat:@"@interface %@ (", self.nameOfClass];
	if (self.isCategory) [result appendString:self.nameOfCategory];
	[result appendString:@")"];
	[result appendString:[super description]];
	return result;
}

@end
