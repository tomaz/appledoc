//
//  AttributesInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "AttributesInfo.h"

@implementation AttributesInfo

#pragma mark - Helper methods

- (NSString *)valueForAttribute:(NSString *)attribute {
	NSUInteger index = [self.attributeItems indexOfObject:attribute];
	if (index == NSNotFound) return nil;
	if (index >= self.attributeItems.count - 2) return nil;
	if (![(self.attributeItems)[index + 1] isEqual:@"="]) return nil;
	return (self.attributeItems)[index + 2];
}

#pragma mark - Properties

- (NSMutableArray *)attributeItems {
	if (_attributeItems) return _attributeItems;
	LogDebug(@"Initializing attribute items array due to first access...");
	_attributeItems = [[NSMutableArray alloc] init];
	return _attributeItems;
}

@end

#pragma mark - 

@implementation AttributesInfo (Registrations)

- (void)appendAttribute:(NSString *)attribute {
	LogVerbose(@"Assigning attribute %@...", attribute);
	[self.attributeItems addObject:attribute];
}

@end

#pragma mark - 

@implementation AttributesInfo (Logging)

- (NSString *)description {
	if (!_attributeItems) return @"";
	NSMutableString *result = [NSMutableString string];
	[self.attributeItems enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
		if (idx > 0) [result appendString:@", "];
		[result appendString:attribute];
	}];
	return result;
}

- (NSString *)debugDescription {
	if (!_attributeItems) return @"";
	return [self description];
}

@end
