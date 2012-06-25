//
//  MethodInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/16/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreConstants.h"
#import "StoreRegistrations.h"
#import "TypeInfo.h"
#import "DescriptorsInfo.h"
#import "MethodArgumentInfo.h"
#import "MethodInfo.h"

@implementation MethodInfo

#pragma mark - Properties

- (TypeInfo *)methodResult {
	if (_methodResult) return _methodResult;
	LogStoDebug(@"Initializing method result due to first access...");
	_methodResult = [[TypeInfo alloc] init];
	return _methodResult;
}

- (DescriptorsInfo *)methodDescriptors {
	if (_methodDescriptors) return _methodDescriptors;
	LogStoDebug(@"Initializing method descriptors due to first access...");
	_methodDescriptors = [[DescriptorsInfo alloc] init];
	return _methodDescriptors;
}

- (NSMutableArray *)methodArguments {
	if (_methodArguments) return _methodArguments;
	LogStoDebug(@"Initializing method arguments array due to first access...");
	_methodArguments = [[NSMutableArray alloc] init];
	return _methodArguments;
}

- (BOOL)isClassMethod {
	return (self.methodType == GBStoreTypes.classMethod);
}

- (BOOL)isInstanceMethod {
	return !self.isClassMethod;
}

@end

#pragma mark - 

@implementation MethodInfo (Registrations)

- (void)beginMethodResults {
	// Note that we don't have to respond to endCurrentObject or cancelCurrentObject to pop methodResult - Store will automatically pop it from its stack whenever either of these messages are sent to it.
	LogStoVerbose(@"Starting method results...");
	[self pushRegistrationObject:self.methodResult];
}

- (void)beginMethodArgument {
	LogStoVerbose(@"Starting method argument...");
	MethodArgumentInfo *argumentInfo = [[MethodArgumentInfo alloc] initWithRegistrar:self.objectRegistrar];
	[self.methodArguments addObject:argumentInfo];
	[self pushRegistrationObject:argumentInfo];
}

- (void)beginMethodDescriptors {
	LogStoVerbose(@"Starting method descriptors...");
	[self pushRegistrationObject:self.methodDescriptors];
}

- (void)cancelCurrentObject {
	if ([self.currentRegistrationObject isKindOfClass:[MethodArgumentInfo class]]) {
		LogStoInfo(@"Cancelling current method argument!");
		[self.methodArguments removeLastObject];
	} else {
		LogWarn(@"Unknown context for cancel current object (%@)!", self.currentRegistrationObject);
	}
}

@end

#pragma mark - 

@implementation MethodInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	[result appendString:self.isClassMethod ? @"+ " : @"- "];
	if (_methodResult) [result appendFormat:@"(%@)", self.methodResult];
	if (_methodArguments) {
		[self.methodArguments enumerateObjectsUsingBlock:^(MethodArgumentInfo *argument, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@" "];
			[result appendFormat:@"%@", argument];
		}];
	}
	if (_methodDescriptors) [result appendFormat:@" %@", self.methodDescriptors];
	[result appendString:@";"];
	return result;
}

@end
