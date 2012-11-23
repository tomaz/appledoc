//
//  EnumInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "EnumItemInfo.h"
#import "EnumInfo.h"

@implementation EnumInfo

#pragma mark - Properties

- (NSMutableArray *)enumItems {
	if (_enumItems) return _enumItems;
	LogDebug(@"Initializing enumeration items array due to first access...");
	_enumItems = [[NSMutableArray alloc] init];
	return _enumItems;
}

@end

#pragma mark - 

@implementation EnumInfo (Registrations)

- (void)appendEnumerationName:(NSString *)name {
	LogVerbose(@"Appending enumeration name %@...", name);
	self.nameOfEnum = name;
}

- (void)appendEnumerationItem:(NSString *)name {
	LogVerbose(@"Creating enumeration item %@...", name);
	EnumItemInfo *info = [[EnumItemInfo alloc] init];
	info.itemName = name;
	[self.enumItems addObject:info];
}

- (void)appendEnumerationValue:(NSString *)value {
	LogVerbose(@"Appending enumeration item value %@...", value);
	if (self.enumItems.count == 0) {
		LogWarn(@"Can't append enumeration value because no item is registered!");
		return;
	}
	EnumItemInfo *info = [self.enumItems lastObject];
	info.itemValue = value;
}

@end

#pragma mark - 

@implementation EnumInfo (Logging)

- (NSString *)description {
	if (!self.nameOfEnum) return @"enum";
	return [NSString gb_format:@"enum %@ w/ %lu items", self.nameOfEnum, 0];
}

- (NSString *)debugDescription {
	NSMutableString *result = [self descriptionStringWithComment];
	[result appendString:@"enum"];
	if (self.nameOfEnum) [result appendFormat:@" %@", self.nameOfEnum];
	[result appendString:@" {\n"];
	if (_enumItems) {
		[self.enumItems enumerateObjectsUsingBlock:^(EnumItemInfo *item, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendFormat:@",\n"];
			[result appendFormat:@"    %@", [item debugDescription]];
		}];
		[result appendString:@"\n"];
	}
	[result appendString:@"}"];
	return result;
}

@end
