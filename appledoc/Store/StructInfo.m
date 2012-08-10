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

#pragma mark - Properties

- (NSMutableArray *)structItems {
	if (_structItems) return _structItems;
	LogIntDebug(@"Initializing struct items array due to first access...");
	_structItems = [[NSMutableArray alloc] init];
	return _structItems;
}

@end

#pragma mark - 

@implementation StructInfo (Registrations)

- (void)appendStructName:(NSString *)name {
	LogStoInfo(@"Appending struct name %@...", name);
	self.nameOfStruct = name;
}

- (void)beginConstant {
	LogStoVerbose(@"Starting constant...");
	ConstantInfo *info = [[ConstantInfo alloc] initWithRegistrar:self.objectRegistrar];
	info.sourceToken = self.currentSourceInfo;
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
	NSMutableString *result = [self descriptionStringWithComment];
	[result appendString:@"struct"];
	if (self.nameOfStruct) [result appendFormat:@" %@", self.nameOfStruct];
	[result appendString:@" {\n"];
	if (_structItems) {
		[self.structItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[result appendFormat:@"    %@;\n", obj];
		}];
	}
	[result appendString:@"}"];
	return result;
}

@end
