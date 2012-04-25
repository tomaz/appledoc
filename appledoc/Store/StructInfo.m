//
//  StructInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "ConstantInfo.h"
#import "StructInfo.h"

@implementation StructInfo

@synthesize structItems = _structItems;

#pragma mark - Properties

- (NSMutableArray *)structItems {
	if (_structItems) return _structItems;
	LogStoDebug(@"Initializing struct items array due to first access...");
	_structItems = [[NSMutableArray alloc] init];
	return _structItems;
}

@end

#pragma mark - 

@implementation StructInfo (Registrations)

- (void)beginConstant {
	LogStoVerbose(@"Starting constant...");
	ConstantInfo *info = [[ConstantInfo alloc] initWithRegistrar:self.objectRegistrar];
	[self.structItems addObject:info];
	[self pushRegistrationObject:info];
}

- (void)cancelCurrentObject {
	LogStoInfo(@"Cancelling current struct item...");
	[self.structItems removeLastObject];
}

@end

#pragma mark - 

@implementation StructInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	[result appendString:@"struct {\n"];
	if (_structItems) {
		[self.structItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendFormat:@"    %@;\n", obj];
		}];
	}
	[result appendString:@"}"];
	return result;
}

@end
