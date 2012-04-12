//
//  Store.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/19/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"

@interface Store ()
@property (nonatomic, strong) PKToken *currentSourceInfo;
@property (nonatomic, strong) NSMutableArray *registrationStack;
@property (nonatomic, readonly) id currentRegistrationObject;
@end

#pragma mark - 

@implementation Store

@synthesize currentSourceInfo = _currentSourceInfo;
@synthesize currentRegistrationObject = _currentRegistrationObject;
@synthesize registrationStack = _registrationStack;

#pragma mark - Forwarding registrations to objects

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	// Pass selector over to current registration object. If it doesn't recognize it, runtime will fail with "unrecognized selector sent to instance" message. Note that this message is only sent for unrecognized selectors, so we don't have to check our superclass!
	LogStoDebug(@"Getting signature for %@...", NSStringFromSelector(selector));
	return [self.currentRegistrationObject methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	// If current registration object responds to given method, pass it over, otherwise fail.
	if ([self.currentRegistrationObject respondsToSelector:invocation.selector]) {
		LogStoDebug(@"Forwarding %@ to %@...", NSStringFromSelector(invocation.selector), self.currentRegistrationObject);
		[invocation invokeWithTarget:self.currentRegistrationObject];
		return;
	}
	[self doesNotRecognizeSelector:invocation.selector];
}

#pragma mark - Properties

- (id)currentRegistrationObject {
	return [self.registrationStack lastObject];
}

- (NSMutableArray *)registrationStack {
	if (_registrationStack) return _registrationStack;
	LogStoDebug(@"Initializing registration stack due to first access...");
	_registrationStack = [[NSMutableArray alloc] init];
	return _registrationStack;
}

@end

#pragma mark - 

@implementation Store (Registrations)

#pragma mark - Classes, categories and protocols handling

- (void)beginClassWithName:(NSString *)name derivedFromClassWithName:(NSString *)derived {
	LogStoInfo(@"Starting class %@ derived from %@...", name, derived);
}

- (void)beginExtensionForClassWithName:(NSString *)name {
}

- (void)beginCategoryWithName:(NSString *)category forClassWithName:(NSString *)name {
}

- (void)beginProtocolWithName:(NSString *)name {
}

- (void)appendAdoptedProtocolWithName:(NSString *)name {
}

#pragma mark - Method groups

- (void)beginMethodGroup {
}

- (void)appendMethodGroupDescription:(NSString *)description {
}

#pragma mark - Properties

- (void)beginPropertyDefinition {
}

- (void)beginPropertyAttributes {
}

- (void)appendPropertyName:(NSString *)name {
}

#pragma mark - Methods

- (void)beginMethodDefinition {
}

- (void)appendMethodType:(NSString *)type {
}

- (void)beginMethodArgument {
}

- (void)appendMethodArgumentSelector:(NSString *)name {
}

- (void)appendMethodArgumentVariable:(NSString *)name {
}

#pragma mark - Enumerations

- (void)beginEnumeration {
}

- (void)appendEnumerationItem:(NSString *)name {
}

- (void)appendEnumerationValue:(NSString *)value {
}

#pragma mark - Structs

- (void)beginStruct {
}

#pragma mark - Constants

- (void)beginConstant {
}

- (void)appendConstantType:(NSString *)type {
}

- (void)appendConstantName:(NSString *)name {
}

#pragma mark - General objects

- (void)beginTypeDefinition {
}

- (void)appendType:(NSString *)type {
}

#pragma mark - Finalizing registration for current object

- (void)endCurrentObject {
}

- (void)cancelCurrentObject {
}

@end
