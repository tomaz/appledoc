//
//  TypeInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/17/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "TypeInfo.h"

@implementation TypeInfo

#pragma mark - Properties

- (NSMutableArray *)typeItems {
	if (_typeItems) return _typeItems;
	LogIntDebug(@"Initializing type items array due to first access...");
	_typeItems = [[NSMutableArray alloc] init];
	return _typeItems;
}

@end

#pragma mark - 

@implementation TypeInfo (Registrations)

- (void)appendType:(NSString *)type {
	LogStoVerbose(@"Appending type '%@'...", type);
	[self.typeItems addObject:type];
}

@end

#pragma mark - 

@implementation TypeInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	if (_typeItems && self.typeItems.count > 0) {
		[self.typeItems enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@" "];
			[result appendString:type];
		}];
	}
	return result;
}

@end
