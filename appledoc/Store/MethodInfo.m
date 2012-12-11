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
#import "CommentInfo.h"
#import "TypeInfo.h"
#import "DescriptorsInfo.h"
#import "MethodArgumentInfo.h"
#import "MethodInfo.h"

@interface MethodInfo ()
@property (nonatomic, readwrite, copy) NSString *methodSelector;
@property (nonatomic, readonly) NSString *methodPrefix;
@end

#pragma mark -

@implementation MethodInfo

#pragma mark - Properties

- (TypeInfo *)methodResult {
	if (_methodResult) return _methodResult;
	LogDebug(@"Initializing method result due to first access...");
	_methodResult = [[TypeInfo alloc] init];
	return _methodResult;
}

- (DescriptorsInfo *)methodDescriptors {
	if (_methodDescriptors) return _methodDescriptors;
	LogDebug(@"Initializing method descriptors due to first access...");
	_methodDescriptors = [[DescriptorsInfo alloc] init];
	return _methodDescriptors;
}

- (NSMutableArray *)methodArguments {
	if (_methodArguments) return _methodArguments;
	LogDebug(@"Initializing method arguments array due to first access...");
	_methodArguments = [[NSMutableArray alloc] init];
	return _methodArguments;
}

- (NSString *)methodSelector {
	if (_methodSelector) return _methodSelector;
	NSMutableString *result = [@"" mutableCopy];
	[self.methodArguments enumerateObjectsUsingBlock:^(MethodArgumentInfo *argumentInfo, NSUInteger idx, BOOL *stop) {
		[result appendString:argumentInfo.argumentSelector];
		if (argumentInfo.isUsingVariable) [result appendString:@":"];
	}];
	_methodSelector = result;
	return _methodSelector;
}

- (NSString *)methodPrefix {
	return (self.methodType == GBStoreTypes.classMethod) ? @"+" : @"-";
}

- (NSString *)descriptionWithInterface:(ObjectInfoBase *)interface {
	return [NSString stringWithFormat:@"%@[%@ %@]", self.methodPrefix, interface.uniqueObjectID, self.methodSelector];
}

- (NSString *)uniqueObjectID {
	return [NSString stringWithFormat:@"%@%@", self.methodPrefix, self.methodSelector];
}

- (NSString *)objectCrossRefPathTemplate {
	return [NSString stringWithFormat:@"#%@", self.uniqueObjectID];
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
	LogVerbose(@"Starting method results...");
	[self pushRegistrationObject:self.methodResult];
}

- (void)beginMethodArgument {
	LogVerbose(@"Starting method argument...");
	MethodArgumentInfo *argumentInfo = [[MethodArgumentInfo alloc] initWithRegistrar:self.objectRegistrar];
	[self.methodArguments addObject:argumentInfo];
	[self pushRegistrationObject:argumentInfo];
}

- (void)beginMethodDescriptors {
	LogVerbose(@"Starting method descriptors...");
	[self pushRegistrationObject:self.methodDescriptors];
}

- (void)cancelCurrentObject {
	if ([self.currentRegistrationObject isKindOfClass:[MethodArgumentInfo class]]) {
		LogVerbose(@"Cancelling current method argument!");
		[self.methodArguments removeLastObject];
	} else {
		LogWarn(@"Unknown context for cancel current object (%@)!", self.currentRegistrationObject);
	}
}

@end

#pragma mark - 

@implementation MethodInfo (Logging)

- (NSString *)description {
	if (!_methodArguments) return @"method";
	NSMutableString *result = [NSMutableString string];
	[result appendString:self.methodPrefix];
	if (_methodArguments) {
		[self.methodArguments enumerateObjectsUsingBlock:^(MethodArgumentInfo *argument, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@" "];
			[result appendFormat:@"%@", argument];
		}];
	}
	return result;
}

- (NSString *)debugDescription {
	NSMutableString *result = [self descriptionStringWithComment];
	[result appendString:self.methodPrefix];
	if (_methodResult) [result appendFormat:@"(%@)", self.methodResult];
	if (_methodArguments) {
		[self.methodArguments enumerateObjectsUsingBlock:^(MethodArgumentInfo *argument, NSUInteger idx, BOOL *stop) {
			if (idx > 0) [result appendString:@" "];
			[result appendFormat:@"%@", [argument debugDescription]];
		}];
	}
	if (_methodDescriptors) [result appendFormat:@" %@", [self.methodDescriptors debugDescription]];
	[result appendString:@";"];
	if (self.comment.sourceString.length > 0) [result appendString:@"\n"];
	return result;
}

@end
