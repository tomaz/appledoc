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

@synthesize attributeItems = _attributeItems;

#pragma mark - Helper methods

- (NSString *)valueForAttribute:(NSString *)attribute {
	NSUInteger index = [self.attributeItems indexOfObject:attribute];
	if (index == NSNotFound) return nil;
	if (index >= self.attributeItems.count - 2) return nil;
	if (![[self.attributeItems objectAtIndex:index + 1] isEqual:@"="]) return nil;
	return [self.attributeItems objectAtIndex:index + 2];
}

#pragma mark - Properties

- (NSMutableArray *)attributeItems {
	if (_attributeItems) return _attributeItems;
	LogIntDebug(@"Initializing attribute items array due to first access...");
	_attributeItems = [[NSMutableArray alloc] init];
	return _attributeItems;
}

@end

#pragma mark - 

@implementation AttributesInfo (Registrations)

- (void)appendAttribute:(NSString *)attribute {
	LogStoInfo(@"Assigning attribute %@...", attribute);
	[self.attributeItems addObject:attribute];
}

@end

#pragma mark - 

@implementation AttributesInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	if (_attributeItems && self.attributeItems.count > 0) {
		[self.attributeItems enumerateObjectsUsingBlock:^(NSString *attribute, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@", "];
			[result appendString:attribute];
		}];
	}
	return result;
}

@end
