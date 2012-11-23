//
//  MethodArgumentInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/18/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "TypeInfo.h"
#import "MethodArgumentInfo.h"

@implementation MethodArgumentInfo

#pragma mark - Properties

- (TypeInfo *)argumentType {
	if (_argumentType) return _argumentType;
	LogDebug(@"Initializing method argument type due to first access...");
	_argumentType = [[TypeInfo alloc] init];
	return _argumentType;
}

- (BOOL)isUsingVariable {
	return (_argumentType || _argumentVariable);
}

@end

#pragma mark - 

@implementation MethodArgumentInfo (Registrations)

- (void)beginMethodArgumentTypes {
	// Note that we don't have to respond to endCurrentObject or cancelCurrentObject to pop argumentType - Store will automatically pop it from its stack whenever either of these messages are sent to it.
	LogVerbose(@"Starting method argument types...");
	[self pushRegistrationObject:self.argumentType];
}

- (void)appendMethodArgumentSelector:(NSString *)name {
	LogVerbose(@"Assigning method argument selector %@...", name);
	self.argumentSelector = name;
}

- (void)appendMethodArgumentVariable:(NSString *)name {
	LogVerbose(@"Assigning method argument variable %@...", name);
	self.argumentVariable = name;
}

@end

#pragma mark - 

@implementation MethodArgumentInfo (Logging)

- (NSString *)description {
	if (!self.argumentSelector) return @"method argument ";
	NSMutableString *result = [NSMutableString string];
	[result appendString:self.argumentSelector];
	if (self.isUsingVariable) [result appendString:@":"];
	return result;
}

- (NSString *)debugDescription {
	NSMutableString *result = [NSMutableString string];
	[result appendString:self.argumentSelector];
	if (self.isUsingVariable) {
		[result appendString:@":"];
		if (_argumentType) [result appendFormat:@"(%@)", self.argumentType];
		if (_argumentVariable) [result appendString:self.argumentVariable];
	}
	return result;
}

@end
