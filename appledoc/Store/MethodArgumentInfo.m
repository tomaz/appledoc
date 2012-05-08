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

@synthesize argumentType = _argumentType;
@synthesize argumentSelector = _argumentSelector;
@synthesize argumentVariable = _argumentVariable;

#pragma mark - Properties

- (TypeInfo *)argumentType {
	if (_argumentType) return _argumentType;
	LogIntDebug(@"Initializing method argument type due to first access...");
	_argumentType = [[TypeInfo alloc] init];
	return _argumentType;
}

@end

#pragma mark - 

@implementation MethodArgumentInfo (Registrations)

- (void)beginMethodArgumentTypes {
	// Note that we don't have to respond to endCurrentObject or cancelCurrentObject to pop argumentType - Store will automatically pop it from its stack whenever either of these messages are sent to it.
	LogStoVerbose(@"Starting method argument types...");
	[self pushRegistrationObject:self.argumentType];
}

- (void)appendMethodArgumentSelector:(NSString *)name {
	LogStoInfo(@"Assigning method argument selector %@...", name);
	self.argumentSelector = name;
}

- (void)appendMethodArgumentVariable:(NSString *)name {
	LogStoInfo(@"Assigning method argument variable %@...", name);
	self.argumentVariable = name;
}

@end

#pragma mark - 

@implementation MethodArgumentInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	[result appendString:self.argumentSelector];
	if (_argumentType || _argumentVariable) {
		[result appendString:@":"];
		if (_argumentType) [result appendFormat:@"(%@)", self.argumentType];
		if (_argumentVariable) [result appendString:self.argumentVariable];
	}
	return result;
}

@end
